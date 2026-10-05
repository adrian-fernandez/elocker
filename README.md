# eLocker — Multi-tenant Locker Platform

Rails test assignment. A web app where multiple tenant companies manage their
smart lockers, and eLocker platform staff can see and operate everything.

**Stack:** Ruby 3.4 · Rails 8.1 · PostgreSQL 17 · Hotwire · Bootstrap 5.3.
Everything else lives in `Gemfile` / `Gemfile.lock`.

---

## Setup — one command

```bash
bin/bootstrap
```

Builds the images, starts the containers, waits for Postgres, prepares and
seeds the DB. Idempotent — safe to re-run.

Then open <http://localhost:3000>. The navbar dropdown (top-right) switches
between seeded users.

Day-to-day commands:

```bash
docker compose up -d           # start
docker compose logs -f web     # tail logs
bin/run bundle exec rspec      # run specs inside the container
bin/run bin/rails console      # Rails console inside the container
docker compose stop            # stop (keep data)
```

## Uninstall

```bash
docker compose down            # remove containers, keep volumes + images
docker compose down -v         # also drop the DB volume
docker compose down -v --rmi local && docker image prune -f   # nuke everything
```

---

## What's in this build

### Lo que pedía el enunciado (done)

- [x] **Multi-tenant model** — Companies, Teams, Users, Lockers with per-team
      access, isolated at the DB level with composite tenant FKs.
- [x] **Platform-owner role** — eLocker staff see and operate every locker;
      tenants only see their teams' lockers.
- [x] **Open / Close actions** — persisted request + device response as an
      append-only `LockerAction` log; current status cached on `lockers`.
- [x] **Access rules really work** — three defence layers (DB composite FKs
      → `VisibleTo` services → controller scoping) with 403 for forbidden and
      404 for invisible resources.
- [x] **Seeded data, no CRUD screens needed** — 3 companies, 6 users, 5
      teams, 5 contracts + 2 spare devices, 8 pre-populated actions.
- [x] **Mocked auth** — `Sessions::SwitchUser` + navbar dropdown. Swapping
      for real SSO is a one-service replacement.
- [x] **Mocked hardware** — `Lockers::Api::Mock` always succeeds; `Http`
      stub shows the extension seam.
- [x] **Specs** — RSpec, 236 examples, 100% line + branch coverage on
      `app/{controllers,models,helpers,services}`.

### Extras — why they are here

Each extra below exists for a specific reason, not for breadth. They are small
on their own but they land in places where "add it later" means a migration
over data that already exists.

- **PhysicalDevice + Locker-as-contract separation.** Hardware has a stable
  `device_id`; ownership is a time-sliced `Locker` row with `started_at` /
  `ended_at`. Transferring a device archives the current contract and opens
  a new one; `LockerAction` rows stay pinned to the archived contract as
  immutable audit. In the real world a device moves across tenants (resold,
  relocated, returned) — building this on day one is cheap; retrofitting
  later means rewriting history.
- **`Lockers::Transfer` service** — authz, serialise concurrent transfers
  via `physical_device.lock!`, archive previous contract + strip its team
  permissions, create new contract, keep action history. One place to
  reason about ownership transitions.
- **Table filters as atomic services** — each `*/filter.rb` exposes one
  `by_<something>` method per filter, idempotent on blank input, composed
  in a short `#call`. Adding a new filter = one method + one line. Example
  of how I organise service code when there is more than one "action":
  thin controller, DI-friendly service, zero inheritance beyond
  `ApplicationService`.
- **Device drivers via Strategy + factory** (`Lockers::Api::{Base, Mock,
  Http}` + `Lockers::Api.for(locker:)`). An example of a scalable solution
  when there will likely be more than one hardware model — adding a driver
  is a new subclass + one line in the `DRIVERS` registry; operators keep
  depending on the abstract base, never on a concrete driver.
- **Dependency injection on every service.** Honest take: this is
  over-engineering for a project of this size — I'd never add this much
  seam for a 3-model CRUD. It is here as a sample of how I design services
  when extensibility matters: every collaborator (visibility, filter,
  paginator, API driver, platform-owner checker) is a kwarg with a
  real-class default, so swapping or wrapping it is a parameter change,
  not a refactor. The payoff shows up in the specs — class doubles stand
  in for the real services without any monkey patching.
- **Force Open / Force Close** — operator with a `force: true` flag that
  skips the "already in target state" validation and marks the resulting
  action as `forced` in the activity log. Covers the real "the device
  drifted out of sync, resend the command" case; the activity log shows
  it clearly so the audit still makes sense.
- **Partitioned `locker_actions` + optimised index set.** Monthly RANGE
  partitioning on `created_at`. Write-side tuning (see below) because this
  is a write-heavy workload — actions dominate traffic, reads are small
  joined selects.
- **Hotwire live refresh** — `broadcast_refresh_to "lockers"` + Morph on
  every open page. Operating a locker in one tab updates every other open
  session instantly.
- **System specs with rack_test** (locker open/close flow + transfer
  flow) on top of request specs for the real HTTP contract.
- **Prosopite** scanning request + system specs so a new view with a
  missing `.includes` fails the test, not a reviewer's eyeballs.

### Write-heavy index strategy

Actions outpace reads at steady state (every open/close is one or two
inserts; a user may browse once a day). I kept the indexes that pay for
themselves on the known hot queries and dropped six that cost on every
insert without a matching read path:

- Partition `locker_actions` by month → old-partition writes stay off the
  current `BRIN`-friendly hot pages; drop-partition instead of
  `DELETE WHERE created_at < ...`.
- Kept composite indexes that back real queries: `(locker_id, created_at)`,
  `(company_id, created_at)` for timeline reads.
- Dropped `created_at` plain, `(user_id, created_at)`, and three
  `lockers`-level indexes that nothing queries by (`ended_at`,
  `last_status_changed_at`, `last_status_changed_by_id`, plain
  `company_id`). ~12M btree ops/day saved at target scale, with zero
  impact on read paths — the partial indexes we kept cover the actual
  queries.
- ILIKE search on names uses `pg_trgm` GIN indexes — plain btree can't
  satisfy `%foo%` and would seq-scan at this volume.

Insert cost matters as much as update cost: every index is "pay once per
insert" so an unused index is pure overhead, not just a mild
inefficiency.

### Omitido — out of scope on purpose

Each item is a 15 to 60-minute add; the trade-off was depth on the
required scope over breadth of extras.

- **Async device responses** (webhook endpoint receiving `opened` /
  `closed` without a prior request, device heartbeats). Current mock is
  synchronous. Would be a nice demo touch but it drags in Solid Queue
  wiring, idempotency keys, and reconciliation logic — all beyond the
  brief, which asks for a mocked driver.
- **Randomised connection failures in the Mock driver** (e.g. 5% of calls
  return a `Response.failure` for demoing the DeviceError flow in the
  UI). Easy win for a visual demo; I left it off to keep the suite
  deterministic. The failure path IS covered by stubbing the driver in a
  request spec, which is the signal that matters.
- **Real authentication / SSO** — brief says mock the user; the whole
  policy layer is wired against `current_user`, so swapping for Devise or
  SAML touches a single service.
- **Admin CRUD UI** for tenants/teams/users — brief marks it out of
  scope.
- **Rate limiting** on write endpoints via Rack::Attack.
- **Observability stack** (Lograge, Sentry, APM).
- **Fragment / Russian-doll caching** on action rows — would help past a
  few thousand actions per page; pagination keeps us under the pain
  threshold for now.
- **CSV / NDJSON export** of the activity log for BI / compliance.
- **Mobile-polished UI**, pretty 404/500 pages, secondary locale
  (`es.yml` scaffold is already there).

---

## Data model (one picture, no 50-line table)

```
┌──────────────────┐                 ┌───────────────┐
│ PhysicalDevice   │                 │     User      │
│ (hardware)       │                 │               │
└────────┬─────────┘                 └───────┬───────┘
         │ 1..N contracts over time          │ HABTM teams_users
         ▼                                   │
┌────────────────────────────────┐           │
│          Locker                │           ▼
│ (contract: physical_device_id, │     ┌───────────┐
│  company_id NULLABLE,          │     │   Team    │
│  started_at, ended_at)         │     └─────┬─────┘
└──┬────────────────────┬────────┘           │
   │ perms              │ actions            │
   ▼                    ▼                    ▼
┌──────────────────┐  ┌─────────────┐  ┌──────────┐
│ LockerTeam       │  │ LockerAction│  │ Company  │
│ Permission       │  └──────┬──────┘  │ (tenant /│
└────────┬─────────┘         │         │ platform)│
         └───────────────────┴────────▶└──────────┘
```

Only the row with `ended_at IS NULL` is current. A partial unique on
`(physical_device_id) WHERE ended_at IS NULL` makes a double-active-contract
impossible at the DB level. `locker_actions` is append-only; its
`company_id` is a snapshot of ownership at action time, so transferring a
device never rewrites history.

Composite tenant FKs on every join table (`teams_users`,
`locker_team_permissions`, `locker_actions`) make cross-tenant rows
impossible even in raw SQL. Model specs assert this with raw inserts
that must raise `ActiveRecord::StatementInvalid`.

---

## Testing

```bash
bin/run bundle exec rspec
```

**236 examples**, 0 failures. **100% line + branch coverage on
`app/{controllers,models,helpers,services}`** via SimpleCov (HTML report in
`coverage/index.html`). Set `NO_COVERAGE=1` to skip instrumentation during
fast single-file iterations.

What's covered:

- Model specs on every table — associations, enums, validations, composite
  tenant FKs (verified via raw SQL inserts that must fail).
- Service specs — `Pagination`, `VisibleTo`, every `Filter` per
  `by_*` method, every `Fetcher` end-to-end + with class doubles proving
  DI, `Operators::Open/Close` happy and failure paths including savepoint
  rollback on `DeviceError`, `Transfer` across every scenario (brand-new
  device, rename within the same company, unassign, platform-owner
  rejection, cross-authorisation).
- Request specs for every controller action, including the force path and
  the forbidden-via-service rescue branch.
- System specs with Capybara (rack_test) for the open/close + transfer
  flows.
- Prosopite N+1 scanner on request + system specs.

---

## AI tooling

Claude was used throughout — as a design partner (naming, trade-offs,
audit decisions) and for the mechanical refactor of patterns across every
entity. Every architectural decision was reviewed and accepted or
rejected explicitly; where I disagreed with the first suggestion I
pushed back.

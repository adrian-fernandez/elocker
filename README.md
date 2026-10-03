# eLocker — Multi-tenant Locker Platform

Rails test assignment: a web app for managing smart lockers across multiple tenant
companies, with platform-level ("eLocker") staff that can see and operate every
locker, and tenant employees that can only see the lockers assigned to their
teams.

## Versions

| Component | Version | Where it's pinned |
|---|---|---|
| Ruby | **4.0.1** | `.ruby-version`, `Dockerfile.dev` |
| Rails | **8.1.4** | `Gemfile` |
| PostgreSQL | **16** (alpine) | `compose.yml` (`postgres:16`) |
| Puma | ≥ 5.0 | `Gemfile` |
| pg gem | ~> 1.1 | `Gemfile` |
| Hotwire | turbo-rails 2.0.23 · stimulus-rails 1.3.4 | `Gemfile.lock` |
| Importmap | importmap-rails (default pins) | `config/importmap.rb` |
| Bootstrap | **5.3.3** (CDN, jsDelivr) | `app/views/layouts/application.html.erb` |
| RSpec | rspec-rails 7.1.1 | `Gemfile.lock` |
| Factories | factory_bot_rails 6.5.1 | `Gemfile.lock` |
| Shoulda | shoulda-matchers 6.5.0 | `Gemfile.lock` |

Database adapters, Action Cable broadcast + queue, cache: Rails 8's Solid trio
(`solid_cache`, `solid_queue`, `solid_cable`) — all SQL-backed, no Redis
required.

---

## Table of contents

1. [Running the app](#running-the-app)
2. [Seed data & demo users](#seed-data--demo-users)
3. [Uninstall / cleanup](#uninstall--cleanup)
4. [Data model & reasoning](#data-model--reasoning)
5. [Security mechanisms](#security-mechanisms)
6. [Technical decisions](#technical-decisions)
7. [Features worth highlighting](#features-worth-highlighting)
8. [Out of scope (by design)](#out-of-scope-by-design)
9. [Testing](#testing)
10. [Assumptions & questions I'd ask the business](#assumptions--questions-id-ask-the-business)
11. [ToDo / future work](#todo--future-work)
12. [AI tooling](#ai-tooling)

---

## Running the app

### Prerequisites

- Docker Desktop (or any Docker engine) with `docker compose` v2
- Ports **3000** (web) available on the host; Postgres stays on the compose
  network and is not exposed
- No local Ruby, Postgres, Node, or asset tooling needed — everything runs
  inside containers

### Custom helper scripts

Two tiny wrappers live in `bin/` to keep the day-to-day workflow short:

| Script | What it does | When to use it |
|---|---|---|
| `bin/run <cmd>` | `docker compose exec web <cmd>` — forwards any args to the running web container. | For running `rails`, `rspec`, `bundle`, `rubocop`, etc. inside Docker without typing the compose incantation every time. |
| `bin/setup` | Stock Rails bootstrap: `bundle check` / `install`, `rails db:prepare`, `log:clear tmp:clear`, then `bin/dev`. Supports `--reset` and `--skip-server`. | Run **inside the container** (`bin/run bin/setup`) to re-prepare the DB on a cold start; or outside Docker if you ever develop natively. For the Docker-first flow below, the one-liner `bin/run bin/rails db:prepare db:seed` is faster since the server is already up via compose. |

### First-time setup

```bash
# clone and move into the repo
git clone <this-repo>
cd elocker

# build images + start containers (web + db)
docker compose up -d --build

# create the database, run migrations, and load the seed data
bin/run bin/rails db:prepare db:seed
```

Open http://localhost:3000. The home controller redirects to `/admin/companies`
if you're logged in as an eLocker platform user, or to `/lockers` if you're a
tenant employee. The first user by id is picked by default; use the dropdown in
the top-right of the navbar to switch to any of the seeded users.

### Day-to-day

```bash
# start everything
docker compose up -d

# tail logs
docker compose logs -f web

# run any command inside the web container
bin/run bin/rails console
bin/run bundle exec rspec
bin/run bin/rails db:migrate

# stop containers (keeps data)
docker compose stop
```

### Reset the dev database

```bash
bin/run bin/rails db:drop db:create db:migrate db:seed
```

---

## Seed data & demo users

The seeds create three companies and six users so every scenario in the brief
can be exercised without any admin screens.

| Company | Type | Users | Teams | Lockers |
|---|---|---|---|---|
| **eLocker** | Platform owner | Adrian Support | — (full access) | — |
| **Amazon** | Tenant | Alice · Bob · Carol | Warehouse · Operations · Managers | A1 · A2 · A3 |
| **DPD** | Tenant | David · Emma | Drivers · Operations | D1 · D2 |

Team memberships (teams a user belongs to):

- Alice → `Warehouse`
- Bob → `Warehouse` + `Operations`
- Carol → `Managers`
- David → `Drivers`
- Emma → `Drivers` + `Operations`

Locker-to-team permissions (which teams can operate each locker):

- A1 → `Warehouse` + `Managers`
- A2 → `Warehouse` + `Operations`
- A3 → `Managers`
- D1 → `Drivers` + `Operations`
- D2 → `Drivers` + `Operations`

Pre-populated action history: Amazon A1 has a full open → close cycle, A2 has a
pending close request (no device response), DPD D1 has an open cycle, D2 has a
device-initiated open. `last_status_changed_at` is backfilled to the time of
each locker's last response, not `Time.current`, so the UI shows realistic
timestamps.

### Suggested walkthrough

1. Start as **Adrian Support** (default) → `/admin/*` sections show every tenant.
2. Switch to **Alice (Amazon)** → `/lockers` shows only A1 and A2; the Activity
   view shows only her accessible lockers' history; hitting `/admin/*` returns
   **403**; hitting a locker she can't see (`/lockers/3` for A3) returns **404**.
3. Switch to **Carol (Amazon)** → sees A1 and A3 (Managers team).
4. Open and close a locker — observe the action timeline update live via Turbo
   Streams on other open tabs (`broadcast_refresh_to "lockers"` + Morph).

---

## Uninstall / cleanup

Clean just the containers (keep images cached for next time):

```bash
docker compose down
```

Full teardown including the Postgres volume and the bundle cache:

```bash
docker compose down -v
```

Nuclear option — remove the images too:

```bash
docker compose down -v --rmi local
docker image prune -f
```

---

## Data model & reasoning

```
┌──────────────┐       ┌──────────────────┐       ┌───────────────┐
│   Company    │◄──────│      Team        │──┐    │     User      │
│ (tenant or   │       │                  │  │    │               │
│  platform    │◄──┐   │                  │  │    │               │
│  owner)      │   │   └──────┬───────────┘  │    └───────┬───────┘
└──────────────┘   │          │              └──HABTM─────┤
       ▲           │          │ perms                     │
       │           │          │                           │
       │           │          ▼                           │
       │           │   ┌────────────────────────┐         │
       │           │   │ LockerTeamPermission   │         │
       │           │   └──────┬─────────────────┘         │
       │           │          │                           │
       │           │          ▼                           │
       │           │   ┌──────────────┐                   │
       │           └───│    Locker    │                   │
       │               └──────┬───────┘                   │
       │                      │                           │
       │                      ▼                           │
       │               ┌───────────────────────────┐      │
       └───────────────│       LockerAction        │◄─────┘
                       └───────────────────────────┘
```

### Choices and why

**Company has a `platform_owner` boolean + partial unique index.** One single
company (eLocker) is marked platform owner; the DB enforces that invariant
(`index_companies_on_platform_owner WHERE platform_owner = TRUE`). Users don't
have a role column — the "is this user elevated?" question is answered by
`Users::PlatformOwnerChecker`, a service that currently derives from the user's
company but can evolve to roles/permissions without touching call sites.

**Teams are per-company, access to a locker is explicit through
`LockerTeamPermission`.** A locker and a team must belong to the same company;
a composite unique on `(id, company_id)` on `lockers` and `teams` + composite
FKs on the join table (`locker_team_permissions_locker_company_fk`,
`locker_team_permissions_team_company_fk`) make cross-tenant permissions
impossible at the DB level, not just in Ruby.

**`teams_users` is a HABTM with `company_id` for the same reason.** The
composite FKs guarantee a user can only be in teams of their own company. A
tenant can't accidentally be dropped into another tenant's team even by raw
SQL.

**`LockerAction` is append-only and event-shaped** — four enum values:
`open_request` and `close_request` (user-triggered) + `opened` and `closed`
(device responses). A request without a matching response represents a failed
or pending operation. The current `Locker#status` is the authoritative current
state; actions are the audit trail. This is the Command + Event-Log pattern,
scoped down to be production-grade without being event-sourcing-heavy.

**`locker_actions.company_id` is pinned to the locker's company**, not the
user's, because a platform-owner user operating a tenant's locker produces an
action that belongs to the tenant's history. The composite FK
`(locker_id, company_id) → lockers` enforces this. The simple `user_id` FK is
intentional (no `(user_id, company_id)` composite) because platform-owner users
operate across companies.

**`Locker#last_status_changed_{at,by}` is separate from `updated_at`.** Editing
the locker's name shouldn't move the "last state change" clock. The columns are
populated by `Lockers::Operators::Base#apply_response!`, so every path that
transitions status funnels through the same assignment.

---

## Security mechanisms

The brief explicitly says *"Access rules and data separation between companies
must really work. Please don't mock those."* This section documents every
layer that enforces that, plus the broader security posture of the app.

### Multi-tenant isolation — three layers

1. **DB layer (last line of defence).**
   The schema builds composite `(id, company_id)` unique indexes on
   `companies`-referencing tables (`lockers`, `teams`, `users`) and composite
   foreign keys on every join:
   - `teams_users.(user_id, company_id) → users.(id, company_id)`
   - `teams_users.(team_id, company_id) → teams.(id, company_id)`
   - `locker_team_permissions.(locker_id, company_id) → lockers.(id, company_id)`
   - `locker_team_permissions.(team_id, company_id) → teams.(id, company_id)`
   - `locker_actions.(locker_id, company_id) → lockers.(id, company_id)`

   The result: even running raw SQL cannot create a user in one tenant's team
   from another tenant, or a locker-team permission across tenants. Model
   specs assert these constraints by attempting such inserts and expecting
   `ActiveRecord::StatementInvalid`.

   Deliberately **not** composite: `locker_actions.user_id`. A platform-owner
   user operating a tenant's locker produces an action whose `company_id`
   belongs to the tenant and whose `user_id` belongs to eLocker. The
   composite constraint would prevent this (and did, in an earlier
   iteration — see the second migration edit of `AddTenantIntegrityConstraints`).

2. **Service layer.**
   Every data-fetching service exposes a `VisibleTo` policy:

   - `Lockers::VisibleTo.call(user:)` — `Locker.all` for platform owners;
     for tenants, joins `locker_team_permissions → team → users` and filters
     to the current user's team memberships + their `company_id`.
   - `LockerActions::VisibleTo.call(user:)` — reuses the above as a
     subquery, so "if you can see the locker, you can see its actions"
     cannot drift.
   - `Users::PlatformOwnerChecker.call(user:)` is the **single** answer to
     "is this user elevated?". The `User` model intentionally does **not**
     expose a `platform_owner?` predicate — a model spec guards against
     anyone re-adding one. The policy currently derives from the user's
     company, but can grow into roles/permissions without any call-site
     changes.

3. **Controller layer.**

   | Guard | Where | Effect |
   |---|---|---|
   | `require_platform_owner!` | `Admin::BaseController` (before_action) | Renders a **403 Forbidden** page in-layout; no redirect-to-200. |
   | `scope.find(params[:id])` using `Lockers::VisibleTo` | `LockersController`, `Admin::LockersController` | Raises `ActiveRecord::RecordNotFound` → **404**. Hides existence from unauthorized viewers. |
   | `Operators::Base#authorize!` | Every open/close call | Defence in depth. Even if a caller bypassed the controller `scope.find`, the operator re-checks visibility and raises `NotAllowedError` → 403. |

### HTTP status codes

Chosen on purpose, not accidental:

| Case | Code | Rationale |
|---|---|---|
| Tenant hits `/admin/*` | **403 Forbidden** | The URL space is public; the user is denied, not hidden-from. |
| Tenant GETs `/lockers/:id` outside their scope | **404 Not Found** | Prevents enumeration — tenant can't learn which locker IDs exist. |
| Any user POSTs `/lockers/:id/open` for an invisible locker | **404 Not Found** | Same reason. |
| Operator `NotAllowedError` (defence-in-depth path) | **403 Forbidden** | Reached only if controller scoping was bypassed. |
| Operator `InvalidStateError` (opening an already-open locker) | 302 + flash | Business state issue, not an auth decision. |
| Operator `DeviceError` (driver reported failure) | 302 + flash | Upstream failure, not an auth decision. |
| Admin section as platform owner | 200 | Normal. |

### Transactional integrity

Operator commands run inside
`ActiveRecord::Base.transaction(requires_new: true)`:

- Request action persisted first.
- Driver dispatched.
- On `response.ok?`: response action + locker status update, in the same
  savepoint.
- On any failure (including `DeviceError`): savepoint rolled back → no stray
  request action, no half-applied state.

`requires_new: true` forces a savepoint even if the caller already opened a
transaction (test suites, batch jobs, etc.), so the atomicity guarantee holds
regardless of context.

### Input handling

- **CSRF**: Rails default protection. All state-changing operations use
  `button_to` or `form_with`, which inject an `authenticity_token`.
- **SQL injection**: every filter uses parameterized queries. ILIKE goes
  through `ActiveRecord::Base.sanitize_sql_like(value)` before the `%…%`
  wrap, so `%` and `_` in user input don't become wildcards.
- **XSS**: ERB escapes by default. The only `*_html` I18n keys are
  deliberately named — they interpolate `link_to(...)` output (already
  marked safe by Rails) alongside `h(name)` for the non-admin fallback. No
  stray `.html_safe` or `raw` elsewhere.
- **Mass-assignment**: there are no create/update routes for domain
  resources from end users — companies/teams/users/lockers are
  seed-managed, operations go through typed service calls (`SwitchUser`,
  `Operators::Open/Close`) that whitelist their inputs explicitly. No
  `permit!`, no accepts-nested-attributes.
- **Filter param narrowing**: filter services only ever add `WHERE`
  clauses on top of a `VisibleTo`-scoped relation. Passing
  `?company_id=other_tenant_id` as a tenant produces an empty result set,
  never a cross-tenant leak.

### Session / auth posture

- The session is a signed Rails cookie (default), `httponly: true`,
  `same_site: :lax`. `secure` is set automatically under SSL.
- Authentication itself is **mocked** per brief — any user can switch to any
  other via the navbar dropdown. The policy layer (`Users::PlatformOwnerChecker`,
  `VisibleTo` services) is wired against `current_user` so swapping the
  mock for real auth (Devise/OmniAuth/SSO) only touches `Sessions::ResolveCurrentUser`.
- `Sessions::SwitchUser` takes the session as a parameter, which lets specs
  pass a plain `Hash` instead of monkey-patching Rails internals.

---

## Technical decisions

### Services + dependency injection (entity-first)

Each entity has a self-contained namespace under `app/services/<entity>/`:

```
app/services/
  application_service.rb           # .call(**kwargs) shortcut
  lockers/
    visible_to.rb                  # authorization scope
    filter.rb                      # atomic by_* methods
    fetcher.rb                     # orchestrator (visibility + filter + order + pagination)
    api.rb + api/{base,mock,http,response}.rb   # device drivers (Strategy + factory)
    operators/{base,open,close}.rb # commands (Template Method)
  locker_actions/{visible_to,filter,fetcher}.rb
  users/{filter,fetcher,platform_owner_checker}.rb
  teams/{filter,fetcher,options_for}.rb
  companies/{filter,fetcher}.rb
  sessions/{switch_user,resolve_current_user}.rb
```

All services take their collaborators via keyword args with sensible defaults
pointing at the real classes, so tests can swap any dependency with a double:

```ruby
Lockers::Fetcher.call(
  user: current_user,
  params:,
  visibility: FakeVisibleTo,     # tests
  filter:     FakeFilter,
  paginator:  FakePagination
)
```

### Filters are atomic

Each `Filter` service exposes `by_name`, `by_status`, `by_date_from`, etc. as
public methods, each idempotent on blank input, composed in a short `call`
pipeline. New filter = one new method + one new line in `call`. Easy to test
without touching the rest.

### Pagination

`Pagination` is a `include Enumerable` POJO that encapsulates records +
metadata. Controllers assign `@entity = SomeFetcher.call(...)`; views iterate
`@entity.each` and also read `@entity.total`, `@entity.first_page?`, etc. The
shared `shared/_pagination.html.erb` partial accepts it as `pagination:`.

### Hotwire

- Turbo Drive handles all navigation (no SPA).
- Turbo Streams: `broadcast_refresh_to "lockers"` on Locker create/update/destroy
  and on LockerAction create. All locker pages (`index`, `show`, `/activity`)
  subscribe via `turbo_stream_from "lockers"` → when anyone operates a locker,
  all open tabs refresh via Morph.
- Stimulus `auto-submit` controller supports immediate submit (`change`),
  debounced submit (`input`, 300ms), and "clear sibling + submit" (used by the
  dependent team dropdown).

### Device drivers via inheritance

`Lockers::Api::Base` defines the abstract `open` / `close` interface; `Mock`
responds with `Response.success`; `Http` is a stub showing where a real driver
would plug in. `Lockers::Api.for(locker:, driver: :mock)` is the factory —
adding support for a new hardware model is a new subclass + one line in the
`DRIVERS` registry. Operators depend on this abstraction, never on a concrete
driver.

### I18n for all UI strings

Even for a single-locale app. `config/locales/en.yml` has nested keys under
`navbar`, `activity`, `admin.<entity>`, `locker`, `errors`, etc. Keys ending
in `_html` are the only ones that interpolate pre-escaped content (e.g. a
`link_to`).

---

## Features worth highlighting

- **Dependent dropdowns**: picking a company narrows the Team select to that
  company's teams, server-rendered (no fetch) via a tiny Stimulus `clearThen`
  action that resets the stale team id before submitting.
- **Debounced text filters**: 300 ms since last keystroke, via a Stimulus
  method; no spam of requests.
- **Pagination size demoable**: default 25, selector includes 2 for easy
  demo. Preserves active filters when changing size or paging.
- **Cross-navigation on cells**: clicking a company anywhere drops you into
  that company's teams; clicking a team opens its members; locker name links
  to the locker show.
- **Live activity timeline** per locker + global `/activity` sharing the same
  table partial. Platform owners see the Company filter; tenants don't (their
  actions are already pinned to their company).
- **Operator pattern** with:
  - Authorization via the same `VisibleTo` the UI uses.
  - State validation (can't open an open locker).
  - Transactional request + dispatch + response + status update, with
    savepoint rollback on driver failure.
  - Fully DI-friendly for tests.
- **Pretty 403 page**, no redirect-to-200 for permission denials.

---

## Out of scope (by design)

Things the brief carved out explicitly, mapped to the current build:

| Topic | Brief said | What this build has |
|---|---|---|
| Managing companies/teams/users | "Create them in seed data, no screens needed." | Seeds cover 3 companies, 6 users, 5 teams, 5 lockers, 8 pre-populated actions. I **did** build read-only admin tables for them (companies/teams/users/lockers) because they double as a demonstration surface for the policy and filter layer, but there is no create/update/delete UI. |
| Authentication | "Mock the current user, and let us switch between users with a dropdown menu in the header." | `Sessions::ResolveCurrentUser` picks the first user on cold start; `Sessions::SwitchUser` persists the choice to the session. Navbar dropdown is grouped by company with a `platform` badge for the eLocker group. |
| Real hardware | "Opening or closing a locker is just a state change in the app." | `Lockers::Api::Mock` always succeeds; `Lockers::Api::Base` + `Http` stub + registry factory show the extension seam. |
| Visual design | "The UI is part of the task, but we won't judge how it looks." | Bootstrap 5.3 via CDN; dark navbar; filter cards; accordion for teams; badges and colored states. Not pixel-polished. |
| Deployment | "The app should just run on localhost." | `docker compose up -d --build` → `localhost:3000`. No Kamal, no cloud. |

Things the brief did **not** ask for and I deliberately did **not** add — the
rationale lives in **[ToDo / future work](#todo--future-work)** below:

- Real authentication / SSO
- Rate limiting on write endpoints
- Admin UI for CRUD on tenants
- Device webhook endpoint
- Observability stack (Lograge, Sentry, APM)
- Fragment or Russian-doll caching
- System specs with a real browser
- CSV / NDJSON export

Each is a 15-60 min add; the trade-off was depth on the required scope
(services, policy, Hotwire, specs, data integrity) over breadth of
nice-to-haves.

## Testing

```bash
bin/run bundle exec rspec
```

**151 examples**, 0 failures. Coverage includes:

- **Model specs** for every table — associations (via shoulda matchers), enums,
  unique indexes, and the composite tenant FKs (verified with raw SQL inserts
  that must fail).
- **Service specs**:
  - `Pagination` edge cases (sanitization, clamping, offset, Enumerable).
  - `Lockers::VisibleTo` + `LockerActions::VisibleTo` for both roles.
  - Each `Filter` with one spec per `by_*` method and a composition spec.
  - Each `Fetcher` end-to-end AND with class-level doubles proving DI
    (visibility/filter/paginator all swappable).
  - `Lockers::Api::{Base, Mock}` + factory errors.
  - `Lockers::Operators::{Open, Close}` — authz blocks strangers, state
    validation rejects already-open-opens, happy path creates both actions +
    updates status, driver failure raises `DeviceError` AND rolls back via
    savepoint, DI accepts a stubbed api.
  - `Sessions::SwitchUser` + `Sessions::ResolveCurrentUser`.
  - `Users::PlatformOwnerChecker`.
- **Request specs** for `admin/users#show` (tenant → 403), `/lockers/:id/open`
  (visibility 404, success 302, state 302+flash), `/admin/lockers/:id/open`
  (tenant → 403), `/activity` (platform sees all, tenant scoped).

Shared setup:

- RSpec runs with an `around(:each)` transaction + rollback. This works for
  every spec regardless of whether rspec-rails inferred a Rails type, so
  `spec/services/` is isolated too.
- `ENV['RAILS_ENV'] = 'test'` is forced in `spec/rails_helper.rb` because the
  Docker container boots with `RAILS_ENV=development`.
- `test` database URL has its own `TEST_DATABASE_URL` override in
  `config/database.yml`.

---

## Assumptions & questions I'd ask the business

Assumptions baked into the current design:

- **One company is the platform owner**, enforced by a partial unique index.
- **Every employee of eLocker has full access**; there's no notion yet of
  "support users with scoped access to a subset of tenants". The
  `PlatformOwnerChecker` service is the hook for that evolution.
- **A user belongs to exactly one company**. Cross-company users (e.g., a
  contractor serving two tenants) aren't modelled.
- **A team's lockers permission is binary** (operate / nothing). The initial
  design had read vs. operate; I removed it per the brief ("each team works
  with its own set"). Easy to add back on `LockerTeamPermission`.
- **Open/close is idempotent against state**: trying to open an already-open
  locker returns `InvalidStateError`. In some real deployments, a resend might
  be legitimate (device drift).
- **Device responses always arrive**: the Mock driver always succeeds. Real
  deployments need timeouts, retries, and an inconsistency reconciliation path.

Questions I'd ask:

1. **Who provisions tenants, teams, and users** in production? The brief marks
   this out of scope (seed only), but in prod it drives the model: is it a
   Pulse-style self-service portal, or eLocker-ops-only?
2. **Can a user belong to multiple companies?** This single relationship
   simplifies a lot — would need redesign if the answer is yes.
3. **Should a tenant admin exist?** Today there are only platform owners and
   plain tenant employees. A "company admin" who can manage their own teams
   and permissions would be a natural tier.
4. **What's the SLA on device commands?** This drives whether we need an
   async pipeline (Solid Queue already in the Gemfile) and retry policy.
5. **What does "action log" show on a failure?** Currently a request without
   response signals failure implicitly. Would an explicit `*_failed` enum
   value be clearer? Would failures retry automatically?
6. **Audit retention?** Actions are append-only; is there a GDPR-style
   deletion requirement or a retention window?
7. **Device model heterogeneity**: how many hardware types are in flight? The
   Strategy pattern on `Lockers::Api` is cheap to extend; a registry per
   `locker.model` is a trivial addition when we know the shape.
8. **Permissions UI priority**: do operators need UI for granting / revoking
   locker access, or is it exclusively eLocker-ops?

---

## ToDo / future work

Each item below is intentionally **not** in the current build but would matter
for a production rollout. Rough estimates alongside each.

### Security & robustness

- **Row-level lock on open/close** (`@locker.with_lock { ... }`): two
  concurrent operations today can both pass `initial_state_valid?`. In the mock
  world this just produces one extra action; against real hardware it means
  firing a command twice. **~15 min**.
- **Rate limiting** on `POST /lockers/:id/{open,close}` via Rack::Attack. One
  user shouldn't be able to spam a device. **~20 min**.
- **Audit logging** for admin actions (viewing another tenant's data,
  switching users). Would ship to a tamper-evident store. **~1 h**.
- **Security alerts** on anomalous access patterns (same user operating from
  two IPs within seconds, bursts of failed operations, unusual time of day).
  Sentry/Honeybadger for exceptions; a custom cron for policy-based alerts.
- **Real authentication** (Devise or OmniAuth, maybe SSO per-tenant via
  SAML/OIDC). Replaces the mocked switcher.
- **CSP tightening** (currently default); nonce-based inline scripts for the
  Bootstrap CDN. Would also move Bootstrap into the asset pipeline so CSP can
  drop the CDN origin.
- **Secrets management** (Rails credentials + per-env unlocking) — right now
  `.env.local` has a placeholder `secret_key_base`.

### Performance

- **Database indexes**: `(created_at)` plain on `locker_actions` for pure
  date-only filters; `pg_trgm` GIN index on `lockers.name` and `users.name`
  for ILIKE scaling. **~15 min each**.
- **Fragment caching** on the activity table rows (Russian doll keyed on
  `locker_action.cache_key_with_version`). Pays off above a few thousand rows
  per page. **~30 min**.
- **Cursor pagination** for `/activity` as the table grows into the millions
  — the `COUNT` for `.total` is the current linear cost. **~45 min**.
- **Read replicas** for the activity queries once scale demands.
- **Background job for `broadcast_refresh_to`** so the controller returns
  without waiting on ActionCable at high throughput. **~15 min** (Solid Queue
  is already in the Gemfile).

### Observability

- **Lograge** or structured JSON logs with request_id correlation. **~15 min**.
- **Error tracking** (Sentry). **~20 min**.
- **APM** (New Relic, Datadog, Skylight) for N+1 and slow-query visibility.
- **A Grafana board** on operation success rate / device latency once Http
  driver lands.

### Feature gaps / future scope

- **Admin UI for tenant provisioning** (company / team / user CRUD). Currently
  seed-only per the brief.
- **Tenant-admin tier**: a user in a tenant who can manage their own teams
  and locker permissions without being eLocker staff.
- **Read-only vs. operate permission** on `LockerTeamPermission` (the enum
  I removed) — if the business ever needs "see but can't open".
- **Device-initiated events** (webhook endpoint receiving status changes
  without a corresponding request). Today only platform/tenant users trigger.
- **Scheduled operations**: open at X, auto-close after Y minutes idle.
  Needs Solid Queue job + a scheduler.
- **CSV / NDJSON export** of the activity table for compliance/BI.
- **Second locale** (`es.yml`) — the I18n scaffolding is already in place.
- **System specs** (Capybara + Selenium) covering the Turbo Streams + user
  switch flow end-to-end. **~45 min**.
- **Mobile view polish**: the filter card is responsive but the activity
  table at 5 filters wide stacks aggressively; a dedicated mobile layout
  would help.
- **Pretty 404 / 500 pages** instead of Rails defaults.

### Architecture

- **Policy objects** (Pundit-style) if authorization rules keep growing.
  Today the single-service approach is enough.
- **Query objects** for the admin tables that currently hit `includes` with
  big trees — swap for materialized counts if slow.
- **Idempotency keys** on open/close for safer retries from clients.

---

## AI tooling

Claude was used throughout, mostly in two modes:

1. **Design partner**: discussing trade-offs for naming (`AccessibleScope` →
   `VisibleTo`), architecture (`Fetcher` vs. inline composition, atomic filter
   methods, entity-first vs. function-first namespacing), and audit decisions
   (HTTP status codes for authorization denials, composite FKs vs. simple FKs
   on `locker_actions.user_id`).
2. **Mechanical refactor**: applying the chosen pattern across every entity
   (Fetchers, Filters, service specs), running the smoke tests, keeping the
   test suite green after each change.

Every architectural decision in this repo was reviewed and accepted (or
rejected) explicitly — the model was treated as a fast colleague, not an
oracle. Where I disagreed with its first suggestion (e.g. the function-first
namespace proposal) I pushed back and chose the simpler path, and where I
agreed I asked it to apply the pattern consistently across all touchpoints.

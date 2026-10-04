class DropUnusedWriteAmplifyingIndexes < ActiveRecord::Migration[8.1]
  # The app's hot path is write-heavy on locker_actions (every operate
  # inserts request + response) and moderate-write on lockers (status
  # update per operate). Each index on these tables costs a btree write
  # per INSERT / UPDATE that touches an indexed column, so dropping
  # indexes with no identified read query is a straight throughput win.
  #
  # Kept intentionally:
  #   - Partial `_active` indexes (free when the row doesn't match).
  #   - Composite tenant FKs `(id, company_id)` (DB-level isolation).
  #   - `(locker_id, created_at)` and `(company_id, created_at)` on
  #     locker_actions — core of the activity timeline queries.
  #   - pg_trgm GIN indexes (updated rarely on these models).
  #
  # In production this would be `DROP INDEX CONCURRENTLY` to avoid an
  # ACCESS EXCLUSIVE lock on busy tables; dev / tests can use the
  # synchronous form.
  def up
    remove_index :locker_actions, :created_at, if_exists: true
    remove_index :locker_actions, [:user_id, :created_at], if_exists: true

    # Disambiguate: `index_lockers_on_company_id_active` (partial) stays.
    remove_index :lockers, name: :index_lockers_on_company_id, if_exists: true
    remove_index :lockers, :ended_at, if_exists: true
    remove_index :lockers, :last_status_changed_at, if_exists: true
    remove_index :lockers, :last_status_changed_by_id, if_exists: true
  end

  def down
    add_index :locker_actions, :created_at
    add_index :locker_actions, [:user_id, :created_at]

    add_index :lockers, :company_id
    add_index :lockers, :ended_at
    add_index :lockers, :last_status_changed_at
    add_index :lockers, :last_status_changed_by_id
  end
end

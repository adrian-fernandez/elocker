class EnableTrgmAndNameSearchIndexes < ActiveRecord::Migration[8.1]
  # ILIKE '%foo%' can't use a plain btree because of the leading wildcard,
  # so at any non-trivial scale (hundreds of thousands of rows per table)
  # the filter dropdowns would degrade to seq scans. pg_trgm's GIN index
  # on the trigram operator class makes those searches sub-second even at
  # millions of rows.
  #
  # Columns indexed:
  # - companies.name, teams.name, users.name  → admin filter dropdowns.
  # - lockers.name                            → tenant + admin list.
  # - physical_devices.device_id              → admin device search.
  def up
    enable_extension "pg_trgm"

    execute <<~SQL
      CREATE INDEX index_companies_on_name_trgm
      ON companies USING gin (name gin_trgm_ops)
    SQL

    execute <<~SQL
      CREATE INDEX index_users_on_name_trgm
      ON users USING gin (name gin_trgm_ops)
    SQL

    execute <<~SQL
      CREATE INDEX index_teams_on_name_trgm
      ON teams USING gin (name gin_trgm_ops)
    SQL

    execute <<~SQL
      CREATE INDEX index_lockers_on_name_trgm
      ON lockers USING gin (name gin_trgm_ops)
    SQL

    execute <<~SQL
      CREATE INDEX index_physical_devices_on_device_id_trgm
      ON physical_devices USING gin (device_id gin_trgm_ops)
    SQL
  end

  def down
    execute "DROP INDEX IF EXISTS index_companies_on_name_trgm"
    execute "DROP INDEX IF EXISTS index_users_on_name_trgm"
    execute "DROP INDEX IF EXISTS index_teams_on_name_trgm"
    execute "DROP INDEX IF EXISTS index_lockers_on_name_trgm"
    execute "DROP INDEX IF EXISTS index_physical_devices_on_device_id_trgm"
    disable_extension "pg_trgm"
  end
end

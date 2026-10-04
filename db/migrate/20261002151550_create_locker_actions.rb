class CreateLockerActions < ActiveRecord::Migration[8.1]
  # locker_actions is partitioned by `created_at` (monthly RANGE) because:
  # 1. It's append-only, so partitions never need re-balancing.
  # 2. Date-range filters hit a single partition instead of scanning the whole table.
  # 3. Retention / archival becomes `DROP PARTITION` instead of DELETE.
  #
  # Postgres requires every unique index on a partitioned table — including
  # the primary key — to include the partition key, hence the composite PK
  # (id, created_at).
  def up
    execute <<~SQL
      CREATE TABLE locker_actions (
        id bigserial NOT NULL,
        locker_id bigint NOT NULL REFERENCES lockers (id),
        user_id bigint REFERENCES users (id),
        company_id bigint REFERENCES companies (id),
        action integer NOT NULL,
        created_at timestamp(6) NOT NULL,
        updated_at timestamp(6) NOT NULL,
        PRIMARY KEY (id, created_at)
      ) PARTITION BY RANGE (created_at)
    SQL

    # Seed the current month + previous and next, plus a catch-all for
    # anything before. In production this list is managed by a scheduled
    # job (pg_partman / custom cron) that creates partitions ahead of time.
    starts_at = 3.months.ago.beginning_of_month
    (0..5).each do |offset|
      month = starts_at + offset.months
      create_month_partition(month)
    end

    add_index :locker_actions, [:locker_id, :created_at]
    add_index :locker_actions, [:user_id, :created_at]
    add_index :locker_actions, [:company_id, :created_at]
    add_index :locker_actions, :created_at
  end

  def down
    drop_table :locker_actions
  end

  private

  def create_month_partition(month)
    name = "locker_actions_#{month.strftime("%Y_%m")}"
    from = month.strftime("%Y-%m-%d")
    to = (month + 1.month).strftime("%Y-%m-%d")

    execute <<~SQL
      CREATE TABLE #{name}
      PARTITION OF locker_actions
      FOR VALUES FROM ('#{from}') TO ('#{to}')
    SQL
  end
end

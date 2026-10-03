# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_02_151657) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "platform_owner", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform_owner"], name: "index_companies_on_platform_owner", unique: true, where: "(platform_owner = true)"
  end

  create_table "locker_actions", force: :cascade do |t|
    t.bigint "locker_id", null: false
    t.bigint "user_id"
    t.bigint "company_id", null: false
    t.integer "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "created_at"], name: "index_locker_actions_on_company_id_and_created_at"
    t.index ["locker_id", "created_at"], name: "index_locker_actions_on_locker_id_and_created_at"
    t.index ["locker_id"], name: "index_locker_actions_on_locker_id"
    t.index ["user_id", "created_at"], name: "index_locker_actions_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_locker_actions_on_user_id"
  end

  create_table "locker_team_permissions", force: :cascade do |t|
    t.bigint "locker_id", null: false
    t.bigint "team_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locker_id", "company_id"], name: "index_locker_team_permissions_on_locker_id_and_company_id"
    t.index ["locker_id", "team_id"], name: "index_locker_team_permissions_on_locker_id_and_team_id", unique: true
    t.index ["team_id", "company_id"], name: "index_locker_team_permissions_on_team_id_and_company_id"
  end

  create_table "lockers", force: :cascade do |t|
    t.string "name", null: false
    t.string "device_id", null: false
    t.integer "status", default: 0, null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "status"], name: "index_lockers_on_company_id_and_status"
    t.index ["company_id"], name: "index_lockers_on_company_id"
    t.index ["device_id"], name: "index_lockers_on_device_id", unique: true
    t.index ["id", "company_id"], name: "index_lockers_on_id_and_company_id", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "name"], name: "index_teams_on_company_id_and_name", unique: true
    t.index ["company_id"], name: "index_teams_on_company_id"
    t.index ["id", "company_id"], name: "index_teams_on_id_and_company_id", unique: true
  end

  create_table "teams_users", id: false, force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "user_id", null: false
    t.bigint "company_id", null: false
    t.index ["team_id", "company_id"], name: "index_teams_users_on_team_id_and_company_id"
    t.index ["team_id", "user_id"], name: "index_teams_users_on_team_id_and_user_id", unique: true
    t.index ["user_id", "company_id"], name: "index_teams_users_on_user_id_and_company_id"
    t.index ["user_id", "team_id"], name: "index_teams_users_on_user_id_and_team_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["id", "company_id"], name: "index_users_on_id_and_company_id", unique: true
  end

  add_foreign_key "locker_actions", "companies"
  add_foreign_key "locker_actions", "lockers"
  add_foreign_key "locker_actions", "lockers", column: ["locker_id", "company_id"], primary_key: ["id", "company_id"], name: "locker_actions_locker_company_fk"
  add_foreign_key "locker_actions", "users"
  add_foreign_key "locker_team_permissions", "companies"
  add_foreign_key "locker_team_permissions", "lockers"
  add_foreign_key "locker_team_permissions", "lockers", column: ["locker_id", "company_id"], primary_key: ["id", "company_id"], name: "locker_team_permissions_locker_company_fk"
  add_foreign_key "locker_team_permissions", "teams"
  add_foreign_key "locker_team_permissions", "teams", column: ["team_id", "company_id"], primary_key: ["id", "company_id"], name: "locker_team_permissions_team_company_fk"
  add_foreign_key "lockers", "companies"
  add_foreign_key "teams", "companies"
  add_foreign_key "teams_users", "companies"
  add_foreign_key "teams_users", "teams"
  add_foreign_key "teams_users", "teams", column: ["team_id", "company_id"], primary_key: ["id", "company_id"], name: "teams_users_team_company_fk"
  add_foreign_key "teams_users", "users"
  add_foreign_key "teams_users", "users", column: ["user_id", "company_id"], primary_key: ["id", "company_id"], name: "teams_users_user_company_fk"
  add_foreign_key "users", "companies"
end

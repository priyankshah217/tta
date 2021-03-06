# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170515102854) do

  create_table "external_dashboards", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "link",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "platforms", force: :cascade do |t|
    t.integer  "product_id", limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_case_records", force: :cascade do |t|
    t.string   "class_name",           limit: 255
    t.string   "time_taken",           limit: 255
    t.integer  "test_suite_record_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "error_msg",            limit: 65535
    t.string   "status",               limit: 255,   default: "n/a", null: false
  end

  add_index "test_case_records", ["test_suite_record_id"], name: "index_test_case_records_on_test_suite_record_id", using: :btree

  create_table "test_category_mappings", force: :cascade do |t|
    t.string   "test_category",     limit: 255
    t.string   "test_sub_category", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_metadata", force: :cascade do |t|
    t.integer  "platform_id",                 limit: 4,   null: false
    t.string   "ci_job_name",                 limit: 255
    t.string   "os",                          limit: 255, null: false
    t.string   "test_execution_machine_name", limit: 255, null: false
    t.string   "browser_or_device",           limit: 255, null: false
    t.string   "environment",                 limit: 255, null: false
    t.datetime "date_of_execution",                       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "test_category",               limit: 255, null: false
    t.string   "test_report_type",            limit: 255, null: false
    t.string   "test_sub_category",           limit: 255
    t.string   "branch",                      limit: 255, null: false
    t.string   "platform_version",            limit: 255, null: false
    t.string   "ci_build_number",             limit: 255
  end

  create_table "test_step_records", force: :cascade do |t|
    t.integer  "test_case_record_id", limit: 4
    t.string   "step_name",           limit: 255
    t.string   "status",              limit: 255
    t.string   "time_taken",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "error_msg",           limit: 65535
  end

  create_table "test_suite_records", force: :cascade do |t|
    t.integer  "test_metadatum_id",       limit: 4
    t.string   "class_name",              limit: 255
    t.integer  "number_of_tests",         limit: 4
    t.integer  "number_of_errors",        limit: 4
    t.integer  "number_of_failures",      limit: 4
    t.string   "time_taken",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number_of_tests_not_run", limit: 4
    t.integer  "number_of_tests_ignored", limit: 4
  end

end

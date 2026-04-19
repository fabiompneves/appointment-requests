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

ActiveRecord::Schema[8.1].define(version: 2026_04_19_181030) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "appointment_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "desired_date", null: false
    t.time "desired_time", null: false
    t.string "guest_email", null: false
    t.string "guest_name", null: false
    t.bigint "nutritionist_id", null: false
    t.bigint "service_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["guest_email", "status"], name: "index_appointment_requests_on_guest_email_and_status"
    t.index ["guest_email"], name: "index_appointment_requests_on_guest_email"
    t.index ["nutritionist_id", "desired_date", "desired_time"], name: "idx_on_nutritionist_id_desired_date_desired_time_b5621cbc0a"
    t.index ["nutritionist_id", "status"], name: "index_appointment_requests_on_nutritionist_id_and_status"
    t.index ["nutritionist_id"], name: "index_appointment_requests_on_nutritionist_id"
    t.index ["service_id"], name: "index_appointment_requests_on_service_id"
    t.index ["status"], name: "index_appointment_requests_on_status"
  end

  create_table "nutritionists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "location", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["location"], name: "index_nutritionists_on_location"
    t.index ["name"], name: "index_nutritionists_on_name"
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "nutritionist_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_services_on_name"
    t.index ["nutritionist_id", "name"], name: "index_services_on_nutritionist_id_and_name"
    t.index ["nutritionist_id"], name: "index_services_on_nutritionist_id"
  end

  add_foreign_key "appointment_requests", "nutritionists"
  add_foreign_key "appointment_requests", "services"
  add_foreign_key "services", "nutritionists"
end

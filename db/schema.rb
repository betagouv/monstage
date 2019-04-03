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

ActiveRecord::Schema.define(version: 2019_04_03_104915) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "class_rooms", force: :cascade do |t|
    t.string "name"
    t.bigint "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_class_rooms_on_school_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "internship_applications", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "internship_offer_week_id"
    t.text "motivation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aasm_state"
    t.index ["aasm_state"], name: "index_internship_applications_on_aasm_state"
    t.index ["internship_offer_week_id"], name: "index_internship_applications_on_internship_offer_week_id"
    t.index ["user_id"], name: "index_internship_applications_on_user_id"
  end

  create_table "internship_offer_weeks", force: :cascade do |t|
    t.bigint "internship_offer_id"
    t.bigint "week_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "blocked_applications_count", default: 0, null: false
    t.index ["blocked_applications_count"], name: "index_internship_offer_weeks_on_blocked_applications_count"
    t.index ["internship_offer_id"], name: "index_internship_offer_weeks_on_internship_offer_id"
    t.index ["week_id"], name: "index_internship_offer_weeks_on_week_id"
  end

  create_table "internship_offers", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.date "week_day_start"
    t.date "week_day_end"
    t.date "excluded_weeks", array: true
    t.integer "max_candidates"
    t.integer "max_internship_week_number"
    t.string "tutor_name"
    t.string "tutor_phone"
    t.string "tutor_email"
    t.string "employer_website"
    t.text "employer_street"
    t.string "employer_zipcode"
    t.string "employer_city"
    t.boolean "is_public"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "employer_name"
    t.string "operator_names", array: true
    t.string "group_name"
    t.bigint "employer_id"
    t.bigint "school_id"
    t.string "employer_description"
    t.bigint "sector_id"
    t.integer "blocked_weeks_count", default: 0, null: false
    t.index ["coordinates"], name: "index_internship_offers_on_coordinates", using: :gist
    t.index ["discarded_at"], name: "index_internship_offers_on_discarded_at"
    t.index ["employer_id"], name: "index_internship_offers_on_employer_id"
    t.index ["max_internship_week_number", "blocked_weeks_count"], name: "not_blocked_by_weeks_count_index"
    t.index ["school_id"], name: "index_internship_offers_on_school_id"
    t.index ["sector_id"], name: "index_internship_offers_on_sector_id"
  end

  create_table "school_internship_weeks", force: :cascade do |t|
    t.bigint "school_id"
    t.bigint "week_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_school_internship_weeks_on_school_id"
    t.index ["week_id"], name: "index_school_internship_weeks_on_week_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "departement_name"
    t.string "zipcode"
    t.string "code_uai"
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "street"
    t.index ["coordinates"], name: "index_schools_on_coordinates", using: :gist
  end

  create_table "sectors", force: :cascade do |t|
    t.string "name"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "phone"
    t.string "first_name"
    t.string "last_name"
    t.string "operator_name"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "school_id"
    t.date "birth_date"
    t.string "gender"
    t.bigint "class_room_id"
    t.text "resume_educational_background"
    t.text "resume_volunteer_work"
    t.text "resume_other"
    t.text "resume_languages"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
  end

  create_table "weeks", force: :cascade do |t|
    t.integer "number"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number", "year"], name: "index_weeks_on_number_and_year", unique: true
  end

  add_foreign_key "class_rooms", "schools"
  add_foreign_key "internship_applications", "internship_offer_weeks"
  add_foreign_key "internship_applications", "users"
  add_foreign_key "internship_offer_weeks", "internship_offers"
  add_foreign_key "internship_offer_weeks", "weeks"
  add_foreign_key "internship_offers", "schools"
  add_foreign_key "internship_offers", "sectors"
  add_foreign_key "internship_offers", "users", column: "employer_id"
  add_foreign_key "school_internship_weeks", "schools"
  add_foreign_key "school_internship_weeks", "weeks"
  add_foreign_key "users", "class_rooms"
end

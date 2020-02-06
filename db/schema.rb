# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_22_144920) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "unaccent"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

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

  create_table "email_whitelists", force: :cascade do |t|
    t.string "email"
    t.string "zipcode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "email", null: false
    t.text "comment", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aasm_state"
    t.string "zammad_id"
  end

  create_table "groups", force: :cascade do |t|
    t.boolean "is_public"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "internship_applications", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "internship_offer_week_id"
    t.text "motivation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aasm_state"
    t.datetime "approved_at"
    t.datetime "rejected_at"
    t.datetime "convention_signed_at"
    t.datetime "submitted_at"
    t.date "pending_reminder_sent_at"
    t.date "automatically_rejected_at"
    t.index ["aasm_state"], name: "index_internship_applications_on_aasm_state"
    t.index ["internship_offer_week_id"], name: "index_internship_applications_on_internship_offer_week_id"
    t.index ["user_id", "internship_offer_week_id"], name: "uniq_applications_per_internship_offer_week", unique: true
    t.index ["user_id"], name: "index_internship_applications_on_user_id"
  end

  create_table "internship_offer_operators", force: :cascade do |t|
    t.bigint "internship_offer_id"
    t.bigint "operator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["internship_offer_id"], name: "index_internship_offer_operators_on_internship_offer_id"
    t.index ["operator_id"], name: "index_internship_offer_operators_on_operator_id"
  end

  create_table "internship_offer_weeks", force: :cascade do |t|
    t.bigint "internship_offer_id"
    t.bigint "week_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "blocked_applications_count", default: 0, null: false
    t.index ["blocked_applications_count"], name: "index_internship_offer_weeks_on_blocked_applications_count"
    t.index ["internship_offer_id", "week_id"], name: "index_internship_offer_weeks_on_internship_offer_id_and_week_id"
    t.index ["internship_offer_id"], name: "index_internship_offer_weeks_on_internship_offer_id"
    t.index ["week_id"], name: "index_internship_offer_weeks_on_week_id"
  end

  create_table "internship_offers", force: :cascade do |t|
    t.string "title", null: false
    t.integer "max_candidates", default: 1, null: false
    t.integer "internship_offer_weeks_count", default: 0, null: false
    t.string "tutor_name"
    t.string "tutor_phone"
    t.string "tutor_email"
    t.string "employer_website"
    t.text "street", null: false
    t.string "zipcode", null: false
    t.string "city", null: false
    t.boolean "is_public", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "employer_name", null: false
    t.string "old_group"
    t.bigint "employer_id"
    t.bigint "school_id"
    t.bigint "sector_id", null: false
    t.integer "blocked_weeks_count", default: 0, null: false
    t.integer "total_applications_count", default: 0, null: false
    t.integer "convention_signed_applications_count", default: 0, null: false
    t.integer "approved_applications_count", default: 0, null: false
    t.string "employer_type"
    t.string "department", default: "", null: false
    t.string "academy", default: "", null: false
    t.integer "total_male_applications_count", default: 0, null: false
    t.integer "total_male_convention_signed_applications_count", default: 0, null: false
    t.string "remote_id"
    t.string "permalink"
    t.integer "total_custom_track_convention_signed_applications_count", default: 0, null: false
    t.integer "view_count", default: 0, null: false
    t.integer "submitted_applications_count", default: 0, null: false
    t.integer "rejected_applications_count", default: 0, null: false
    t.datetime "published_at"
    t.string "description", default: "", null: false
    t.string "employer_description"
    t.integer "total_male_approved_applications_count", default: 0
    t.integer "total_custom_track_approved_applications_count", default: 0
    t.bigint "group_id"
    t.index ["academy"], name: "index_internship_offers_on_academy"
    t.index ["coordinates"], name: "index_internship_offers_on_coordinates", using: :gist
    t.index ["department"], name: "index_internship_offers_on_department"
    t.index ["discarded_at"], name: "index_internship_offers_on_discarded_at"
    t.index ["employer_id"], name: "index_internship_offers_on_employer_id"
    t.index ["group_id"], name: "index_internship_offers_on_group_id"
    t.index ["internship_offer_weeks_count", "blocked_weeks_count"], name: "not_blocked_by_weeks_count_index"
    t.index ["old_group"], name: "index_internship_offers_on_old_group"
    t.index ["remote_id"], name: "index_internship_offers_on_remote_id"
    t.index ["school_id"], name: "index_internship_offers_on_school_id"
    t.index ["sector_id"], name: "index_internship_offers_on_sector_id"
  end

  create_table "operators", force: :cascade do |t|
    t.string "name"
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
    t.string "name", default: "", null: false
    t.string "city", default: "", null: false
    t.string "department"
    t.string "zipcode"
    t.string "code_uai"
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "street"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.tsvector "city_tsv"
    t.string "kind"
    t.boolean "visible", default: true
    t.index ["city_tsv"], name: "index_schools_on_city_tsv", using: :gin
    t.index ["coordinates"], name: "index_schools_on_coordinates", using: :gist
  end

  create_table "sectors", force: :cascade do |t|
    t.string "name"
    t.string "external_url", default: "", null: false
    t.string "uuid", default: "", null: false
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
    t.text "resume_other"
    t.text "resume_languages"
    t.boolean "has_parental_consent", default: false
    t.bigint "operator_id"
    t.string "api_token"
    t.text "handicap"
    t.boolean "custom_track", default: false, null: false
    t.boolean "accept_terms", default: false, null: false
    t.datetime "discarded_at"
    t.string "zipcode"
    t.string "department_name"
    t.index ["api_token"], name: "index_users_on_api_token"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
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
    t.index ["year"], name: "index_weeks_on_year"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "class_rooms", "schools"
  add_foreign_key "internship_applications", "internship_offer_weeks"
  add_foreign_key "internship_applications", "users"
  add_foreign_key "internship_offer_operators", "internship_offers"
  add_foreign_key "internship_offer_operators", "operators"
  add_foreign_key "internship_offer_weeks", "internship_offers"
  add_foreign_key "internship_offer_weeks", "weeks"
  add_foreign_key "internship_offers", "groups"
  add_foreign_key "internship_offers", "schools"
  add_foreign_key "internship_offers", "sectors"
  add_foreign_key "internship_offers", "users", column: "employer_id"
  add_foreign_key "school_internship_weeks", "schools"
  add_foreign_key "school_internship_weeks", "weeks"
  add_foreign_key "users", "class_rooms"
  add_foreign_key "users", "operators"
end

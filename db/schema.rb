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

ActiveRecord::Schema.define(version: 2019_02_07_111844) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "internship_offers", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "sector"
    t.boolean "can_be_applied_for", default: true
    t.date "week_day_start"
    t.date "week_day_end"
    t.date "excluded_weeks", array: true
    t.integer "max_candidates"
    t.integer "max_weeks"
    t.string "tutor_name"
    t.string "tutor_phone"
    t.string "tutor_email"
    t.string "employer_website"
    t.text "employer_description"
    t.string "supervisor_email"
    t.boolean "is_public"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

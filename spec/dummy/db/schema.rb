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

ActiveRecord::Schema.define(version: 2018_09_07_143741) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.jsonb "data", default: {}, null: false
  end

  create_table "authors", force: :cascade do |t|
    t.hstore "data"
  end

  create_table "books", force: :cascade do |t|
    t.hstore "data"
    t.hstore "another_hstore"
  end

  create_table "cars", force: :cascade do |t|
    t.hstore "data"
  end

  create_table "coffees", force: :cascade do |t|
    t.hstore "data"
  end

  create_table "phones", force: :cascade do |t|
    t.hstore "data"
  end

end

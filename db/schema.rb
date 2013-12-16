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

ActiveRecord::Schema.define(version: 20131216171134) do

  create_table "candidates", force: true do |t|
    t.string  "uid",        null: false
    t.integer "contest_id"
    t.string  "name"
    t.string  "party"
    t.integer "sort_order"
  end

  add_index "candidates", ["contest_id"], name: "index_candidates_on_contest_id", using: :btree
  add_index "candidates", ["uid"], name: "index_candidates_on_uid", unique: true, using: :btree

  create_table "contests", force: true do |t|
    t.string  "uid",         null: false
    t.integer "locality_id"
    t.integer "district_id"
    t.string  "office"
    t.string  "sort_order"
  end

  add_index "contests", ["district_id"], name: "index_contests_on_district_id", using: :btree
  add_index "contests", ["locality_id"], name: "index_contests_on_locality_id", using: :btree
  add_index "contests", ["uid"], name: "index_contests_on_uid", unique: true, using: :btree

  create_table "districts", force: true do |t|
    t.string  "uid",           null: false
    t.integer "state_id"
    t.string  "name"
    t.string  "district_type"
  end

  add_index "districts", ["state_id"], name: "index_districts_on_state_id", using: :btree
  add_index "districts", ["uid"], name: "index_districts_on_uid", unique: true, using: :btree

  create_table "elections", force: true do |t|
    t.integer "state_id",      null: false
    t.string  "uid",           null: false
    t.date    "held_on"
    t.string  "election_type", null: false
    t.boolean "statewide"
  end

  add_index "elections", ["state_id"], name: "index_elections_on_state_id", using: :btree
  add_index "elections", ["uid"], name: "index_elections_on_uid", unique: true, using: :btree

  create_table "localities", force: true do |t|
    t.integer "state_id",      null: false
    t.string  "name",          null: false
    t.string  "locality_type", null: false
    t.string  "uid",           null: false
  end

  add_index "localities", ["state_id"], name: "index_localities_on_state_id", using: :btree
  add_index "localities", ["uid"], name: "index_localities_on_uid", unique: true, using: :btree

  create_table "states", force: true do |t|
    t.string "uid",  null: false
    t.string "code", null: false
    t.string "name"
  end

  add_index "states", ["code"], name: "index_states_on_code", unique: true, using: :btree
  add_index "states", ["uid"], name: "index_states_on_uid", unique: true, using: :btree

end

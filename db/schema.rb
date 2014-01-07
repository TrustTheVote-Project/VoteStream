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

ActiveRecord::Schema.define(version: 20140107070833) do

  create_table "ballot_responses", force: true do |t|
    t.integer "referendum_id"
    t.string  "uid",           null: false
    t.string  "name",          null: false
    t.integer "sort_order"
  end

  add_index "ballot_responses", ["referendum_id"], name: "index_ballot_responses_on_referendum_id", using: :btree
  add_index "ballot_responses", ["uid"], name: "index_ballot_responses_on_uid", unique: true, using: :btree

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
    t.string  "uid",           null: false
    t.integer "district_id"
    t.string  "office"
    t.string  "sort_order"
    t.string  "district_type"
  end

  add_index "contests", ["district_id"], name: "index_contests_on_district_id", using: :btree
  add_index "contests", ["district_type"], name: "index_contests_on_district_type", using: :btree
  add_index "contests", ["uid"], name: "index_contests_on_uid", unique: true, using: :btree

  create_table "districts", force: true do |t|
    t.string "uid",           null: false
    t.string "name"
    t.string "district_type"
  end

  add_index "districts", ["uid"], name: "index_districts_on_uid", unique: true, using: :btree

  create_table "districts_precincts", id: false, force: true do |t|
    t.integer "district_id", null: false
    t.integer "precinct_id", null: false
  end

  add_index "districts_precincts", ["district_id"], name: "index_districts_precincts_on_district_id", using: :btree
  add_index "districts_precincts", ["precinct_id"], name: "index_districts_precincts_on_precinct_id", using: :btree

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

  create_table "polling_locations", force: true do |t|
    t.integer "precinct_id"
    t.string  "name",        null: false
    t.string  "line1"
    t.string  "line2"
    t.string  "city"
    t.string  "state"
    t.string  "zip"
  end

  add_index "polling_locations", ["precinct_id"], name: "index_polling_locations_on_precinct_id", using: :btree

  create_table "precincts", force: true do |t|
    t.integer "locality_id"
    t.string  "uid",         null: false
    t.string  "name",        null: false
    t.text    "kml"
    t.integer "total_cast"
  end

  add_index "precincts", ["locality_id"], name: "index_precincts_on_locality_id", using: :btree
  add_index "precincts", ["uid"], name: "index_precincts_on_uid", unique: true, using: :btree

  create_table "referendums", force: true do |t|
    t.integer "district_id"
    t.string  "uid",         null: false
    t.string  "title",       null: false
    t.text    "subtitle",    null: false
    t.text    "question",    null: false
    t.string  "sort_order"
  end

  add_index "referendums", ["district_id"], name: "index_referendums_on_district_id", using: :btree
  add_index "referendums", ["uid"], name: "index_referendums_on_uid", unique: true, using: :btree

  create_table "states", force: true do |t|
    t.string "uid",  null: false
    t.string "code", null: false
    t.string "name"
  end

  add_index "states", ["code"], name: "index_states_on_code", unique: true, using: :btree
  add_index "states", ["uid"], name: "index_states_on_uid", unique: true, using: :btree

  create_table "voting_results", force: true do |t|
    t.integer "candidate_id"
    t.integer "precinct_id"
    t.integer "votes"
  end

  add_index "voting_results", ["candidate_id"], name: "index_voting_results_on_candidate_id", using: :btree
  add_index "voting_results", ["precinct_id"], name: "index_voting_results_on_precinct_id", using: :btree

end

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

ActiveRecord::Schema.define(version: 20140428181530) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "postgis_topology"

  create_table "ballot_response_results", force: true do |t|
    t.integer "ballot_response_id"
    t.integer "precinct_id"
    t.integer "votes"
    t.string  "uid"
    t.integer "contest_result_id",  null: false
  end

  add_index "ballot_response_results", ["ballot_response_id"], :name => "index_ballot_response_results_on_ballot_response_id"
  add_index "ballot_response_results", ["contest_result_id"], :name => "index_ballot_response_results_on_contest_result_id"
  add_index "ballot_response_results", ["precinct_id"], :name => "index_ballot_response_results_on_precinct_id"
  add_index "ballot_response_results", ["uid"], :name => "index_ballot_response_results_on_uid"

  create_table "ballot_responses", force: true do |t|
    t.integer "referendum_id"
    t.string  "uid",           null: false
    t.string  "name",          null: false
    t.integer "sort_order"
  end

  add_index "ballot_responses", ["referendum_id"], :name => "index_ballot_responses_on_referendum_id"
  add_index "ballot_responses", ["uid"], :name => "index_ballot_responses_on_uid", :unique => true

  create_table "candidate_results", force: true do |t|
    t.integer "candidate_id"
    t.integer "precinct_id"
    t.integer "votes"
    t.string  "uid"
    t.integer "contest_result_id", null: false
  end

  add_index "candidate_results", ["candidate_id"], :name => "index_candidate_results_on_candidate_id"
  add_index "candidate_results", ["contest_result_id"], :name => "index_candidate_results_on_contest_result_id"
  add_index "candidate_results", ["precinct_id"], :name => "index_candidate_results_on_precinct_id"
  add_index "candidate_results", ["uid"], :name => "index_candidate_results_on_uid"

  create_table "candidates", force: true do |t|
    t.string  "uid",        null: false
    t.integer "contest_id"
    t.string  "name"
    t.integer "sort_order"
    t.integer "party_id",   null: false
    t.string  "color"
  end

  add_index "candidates", ["contest_id"], :name => "index_candidates_on_contest_id"
  add_index "candidates", ["uid"], :name => "index_candidates_on_uid", :unique => true

  create_table "contest_results", force: true do |t|
    t.string   "uid",               null: false
    t.string   "certification",     null: false
    t.integer  "precinct_id",       null: false
    t.integer  "contest_id"
    t.integer  "referendum_id"
    t.integer  "total_votes"
    t.integer  "total_valid_votes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color_code"
  end

  add_index "contest_results", ["contest_id"], :name => "index_contest_results_on_contest_id"
  add_index "contest_results", ["precinct_id"], :name => "index_contest_results_on_precinct_id"
  add_index "contest_results", ["referendum_id"], :name => "index_contest_results_on_referendum_id"
  add_index "contest_results", ["uid"], :name => "index_contest_results_on_uid"

  create_table "contests", force: true do |t|
    t.string  "uid",           null: false
    t.integer "district_id"
    t.string  "office"
    t.string  "sort_order"
    t.string  "district_type"
    t.integer "locality_id"
    t.boolean "partisan"
    t.boolean "write_in"
  end

  add_index "contests", ["district_id"], :name => "index_contests_on_district_id"
  add_index "contests", ["district_type"], :name => "index_contests_on_district_type"
  add_index "contests", ["locality_id"], :name => "index_contests_on_locality_id"
  add_index "contests", ["uid"], :name => "index_contests_on_uid", :unique => true

  create_table "districts", force: true do |t|
    t.string  "uid",           null: false
    t.string  "name"
    t.string  "district_type"
    t.integer "locality_id"
  end

  add_index "districts", ["locality_id"], :name => "index_districts_on_locality_id"
  add_index "districts", ["uid", "locality_id"], :name => "index_districts_on_uid_and_locality_id", :unique => true

  create_table "districts_precincts", id: false, force: true do |t|
    t.integer "district_id", null: false
    t.integer "precinct_id", null: false
  end

  add_index "districts_precincts", ["district_id"], :name => "index_districts_precincts_on_district_id"
  add_index "districts_precincts", ["precinct_id"], :name => "index_districts_precincts_on_precinct_id"

  create_table "elections", force: true do |t|
    t.integer "state_id",                                            null: false
    t.string  "uid",                                                 null: false
    t.date    "held_on"
    t.string  "election_type",                                       null: false
    t.boolean "statewide"
    t.decimal "reporting",     precision: 5, scale: 2, default: 0.0, null: false
    t.integer "seq",                                   default: 0,   null: false
  end

  add_index "elections", ["state_id"], :name => "index_elections_on_state_id"
  add_index "elections", ["uid"], :name => "index_elections_on_uid", :unique => true

  create_table "localities", force: true do |t|
    t.integer "state_id",      null: false
    t.string  "name",          null: false
    t.string  "locality_type", null: false
    t.string  "uid",           null: false
  end

  add_index "localities", ["state_id"], :name => "index_localities_on_state_id"
  add_index "localities", ["uid"], :name => "index_localities_on_uid", :unique => true

  create_table "parties", force: true do |t|
    t.string  "uid",         null: false
    t.integer "sort_order"
    t.string  "name",        null: false
    t.string  "abbr",        null: false
    t.integer "locality_id"
  end

  add_index "parties", ["locality_id"], :name => "index_parties_on_locality_id"
  add_index "parties", ["uid", "locality_id"], :name => "index_parties_on_uid_and_locality_id", :unique => true

  create_table "polling_locations", force: true do |t|
    t.integer "precinct_id"
    t.integer "address_id"
    t.string  "name",        null: false
    t.string  "line1"
    t.string  "line2"
    t.string  "city"
    t.string  "state"
    t.string  "zip"
  end

  add_index "polling_locations", ["address_id"], :name => "index_polling_locations_on_address_id"
  add_index "polling_locations", ["precinct_id"], :name => "index_polling_locations_on_precinct_id"

  create_table "precincts", force: true do |t|
    t.integer "locality_id"
    t.string  "uid",                                                  null: false
    t.string  "name",                                                 null: false
    t.text    "kml"
    t.integer "total_cast"
    t.spatial "geo",         limit: {:srid=>4326, :type=>"geometry"}
  end

  add_index "precincts", ["locality_id"], :name => "index_precincts_on_locality_id"
  add_index "precincts", ["uid"], :name => "index_precincts_on_uid", :unique => true

  create_table "referendums", force: true do |t|
    t.integer "district_id"
    t.string  "uid",           null: false
    t.string  "title"
    t.text    "subtitle"
    t.text    "question"
    t.string  "sort_order"
    t.integer "locality_id"
    t.string  "district_type"
  end

  add_index "referendums", ["district_id"], :name => "index_referendums_on_district_id"
  add_index "referendums", ["locality_id"], :name => "index_referendums_on_locality_id"
  add_index "referendums", ["uid"], :name => "index_referendums_on_uid", :unique => true

  create_table "states", force: true do |t|
    t.string "uid",  null: false
    t.string "code", null: false
    t.string "name"
  end

  add_index "states", ["code"], :name => "index_states_on_code", :unique => true
  add_index "states", ["uid"], :name => "index_states_on_uid", :unique => true

end

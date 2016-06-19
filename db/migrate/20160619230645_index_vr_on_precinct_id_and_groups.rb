class IndexVrOnPrecinctIdAndGroups < ActiveRecord::Migration
  def change
    add_index :voter_registrations, [:precinct_id, :voter_outcome], name: :index_vr_on_precinct_and_outcome
    add_index :voter_registrations, [:precinct_id, :sex], name: :index_vr_on_precinct_sex
    add_index :voter_registrations, [:precinct_id, :voter_outcome, :sex], name: :index_vr_on_precinct_outcome_sex
    add_index :voter_registrations, [:precinct_id, :race], name: :index_vr_on_precinct_race
    add_index :voter_registrations, [:precinct_id, :voter_outcome, :race], name: :index_vr_on_precinct_outcome_race
    add_index :voter_registrations, [:precinct_id, :party], name: :index_vr_on_precinct_party
    add_index :voter_registrations, [:precinct_id, :voter_outcome, :party], name: :index_vr_on_precinct_outcome_party
    add_index :voter_registrations, [:precinct_id, :date_of_birth], name: :index_vr_on_precinct_dib
    add_index :voter_registrations, [:precinct_id, :voter_outcome, :date_of_birth], name: :index_vr_on_precinct_outcome_dob
  end
end

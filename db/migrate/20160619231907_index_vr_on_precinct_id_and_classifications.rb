class IndexVrOnPrecinctIdAndClassifications < ActiveRecord::Migration
  def change
    
    add_index :voter_registrations, [:precinct_id, :is_citizen], name: :index_vr_on_precicnt_is_eighteen_election_day
    add_index :voter_registrations, [:precinct_id, :is_citizen, :voter_outcome], name: :index_vr_on_precinct_outcome_is_citizen
    add_index :voter_registrations, [:precinct_id, :is_eighteen_election_day], name: :index_vr_on_precicnt_is_citizen
    add_index :voter_registrations, [:precinct_id, :is_eighteen_election_day, :voter_outcome], name: :index_vr_on_precinct_outcome_is_eighteen_election_day
    add_index :voter_registrations, [:precinct_id, :is_election_absentee], name: :index_vr_on_precicnt_is_election_absentee
    add_index :voter_registrations, [:precinct_id, :is_election_absentee, :voter_outcome], name: :index_vr_on_precinct_outcome_is_election_absentee
    add_index :voter_registrations, [:precinct_id, :is_residing_at_registration_address], name: :index_vr_on_precicnt_is_residing_at_registration_address
    add_index :voter_registrations, [:precinct_id, :is_residing_at_registration_address, :voter_outcome], name: :index_vr_on_precinct_outcome_is_res_reg_address
    add_index :voter_registrations, [:precinct_id, :is_active_duty_uniformed_services], name: :index_vr_on_precicnt_is_active_duty_uniformed_services
    add_index :voter_registrations, [:precinct_id, :is_active_duty_uniformed_services, :voter_outcome], name: :index_vr_on_precinct_outcome_is_adus
    add_index :voter_registrations, [:precinct_id, :is_permanent_absetee], name: :index_vr_on_precicnt_is_permanent_absetee
    add_index :voter_registrations, [:precinct_id, :is_permanent_absetee, :voter_outcome], name: :index_vr_on_precinct_outcome_is_permanent_absetee
    add_index :voter_registrations, [:precinct_id, :is_eligible_military_spouse_or_dependent], name: :index_vr_on_precicnt_is_elig_mil_spouse_or_dep
    add_index :voter_registrations, [:precinct_id, :is_eligible_military_spouse_or_dependent, :voter_outcome], name: :index_vr_on_precinct_outcome_is_eligible_mil_spouse_or_dep
    add_index :voter_registrations, [:precinct_id, :is_residing_abroad_uncertain_return], name: :index_vr_on_precicnt_is_res_abroad_ur
    add_index :voter_registrations, [:precinct_id, :is_residing_abroad_uncertain_return, :voter_outcome], name: :index_vr_on_precinct_outcome_is_res_abroad_ur
    add_index :voter_registrations, [:precinct_id, :is_residing_abroad_with_intent_to_return], name: :index_vr_on_precicnt_is_res_abroad_ir
    add_index :voter_registrations, [:precinct_id, :is_residing_abroad_with_intent_to_return, :voter_outcome], name: :index_vr_on_precinct_outcome_is_res_abroad_ir
    
    
  end
end

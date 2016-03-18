class DenormalizeVoterClassifications < ActiveRecord::Migration
  def change
    
    add_column :voter_registrations, :is_citizen, :boolean, default: false, null: false
    add_column :voter_registrations, :is_eighteen_election_day, :boolean, default: false, null: false
    add_column :voter_registrations, :is_election_absentee, :boolean, default: false, null: false
    add_column :voter_registrations, :is_residing_at_registration_address, :boolean, default: false, null: false
    add_column :voter_registrations, :is_active_duty_uniformed_services, :boolean, default: false, null: false
    add_column :voter_registrations, :is_permanent_absetee, :boolean, default: false, null: false
    add_column :voter_registrations, :is_eligible_military_spouse_or_dependent, :boolean, default: false, null: false
    add_column :voter_registrations, :is_residing_abroad_uncertain_return, :boolean, default: false, null: false
    
    
    add_index :voter_registrations, :is_citizen, name: :index_vr_on_is_citizen
    add_index :voter_registrations, :is_eighteen_election_day, name: :index_vr_on_is_eighteen
    add_index :voter_registrations, :is_election_absentee, name: :index_vr_on_is_absentee
    add_index :voter_registrations, :is_residing_at_registration_address, name: :index_vr_on_is_home
    add_index :voter_registrations, :is_active_duty_uniformed_services, name: :index_vr_on_is_military
    add_index :voter_registrations, :is_permanent_absetee, name: :index_vr_on_is_permane
    add_index :voter_registrations, :is_eligible_military_spouse_or_dependent, name: :index_vr_on_is_military_dep
    add_index :voter_registrations, :is_residing_abroad_uncertain_return, name: :index_vr_on_is_abroad
    
  end
end

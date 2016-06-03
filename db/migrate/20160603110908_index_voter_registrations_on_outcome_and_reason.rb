class IndexVoterRegistrationsOnOutcomeAndReason < ActiveRecord::Migration
  def change
    add_index :voter_registrations, :voter_outcome, name: :index_vr_on_outcome
    add_index :voter_registrations, :voter_rejected_reason, name: :index_vr_on_reason
    
  end
end

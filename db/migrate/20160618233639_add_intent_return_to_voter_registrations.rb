class AddIntentReturnToVoterRegistrations < ActiveRecord::Migration
  def change
    add_column :voter_registrations, :is_residing_abroad_with_intent_to_return, :boolean, default: false, null: false
    add_index :voter_registrations, :is_residing_abroad_with_intent_to_return, name: :index_vr_on_is_abroad_intent_return  
  end
end

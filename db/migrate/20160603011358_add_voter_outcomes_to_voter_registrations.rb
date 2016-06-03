class AddVoterOutcomesToVoterRegistrations < ActiveRecord::Migration
  def change
    add_column :voter_registrations, :voter_outcome, :string
    add_column :voter_registrations, :voter_rejected_reason, :string
  end
end

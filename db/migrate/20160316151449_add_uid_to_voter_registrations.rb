class AddUidToVoterRegistrations < ActiveRecord::Migration
  def change
    add_column :voter_registrations, :uid, :string, null: false, unique: true
  end
end

class AddElectionIdToContests < ActiveRecord::Migration
  def change
    add_column :contests, :election_id, :integer
    add_index :contests, :election_id
  end

end

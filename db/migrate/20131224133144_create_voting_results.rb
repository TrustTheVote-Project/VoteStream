class CreateVotingResults < ActiveRecord::Migration
  def change
    create_table :voting_results do |t|
      t.belongs_to :candidate, index: true
      t.belongs_to :precinct, index: true
      t.integer    :votes
    end
  end
end

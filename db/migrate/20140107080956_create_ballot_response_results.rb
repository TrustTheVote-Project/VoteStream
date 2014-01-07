class CreateBallotResponseResults < ActiveRecord::Migration
  def change
    create_table :ballot_response_results do |t|
      t.references  :ballot_response, index: true
      t.references  :precinct, index: true
      t.integer     :votes
    end
  end
end

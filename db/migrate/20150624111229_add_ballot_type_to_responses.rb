class AddBallotTypeToResponses < ActiveRecord::Migration
  def change
    add_column :ballot_response_results, :ballot_type, :string
    add_column :candidate_results, :ballot_type, :string
  end
end

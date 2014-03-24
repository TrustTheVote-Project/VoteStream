class AddUidsToResultTables < ActiveRecord::Migration
  def change
    add_column :candidate_results, :uid, :string
    add_column :ballot_response_results, :uid, :string
    add_index  :candidate_results, :uid
    add_index  :ballot_response_results, :uid
  end
end

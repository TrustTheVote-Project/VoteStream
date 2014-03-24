class AddContestResultIdToResultsTables < ActiveRecord::Migration
  def change
    add_column :ballot_response_results, :contest_result_id, :integer, null: false
    add_index  :ballot_response_results, :contest_result_id
    add_column :candidate_results, :contest_result_id, :integer, null: false
    add_index  :candidate_results, :contest_result_id
  end
end

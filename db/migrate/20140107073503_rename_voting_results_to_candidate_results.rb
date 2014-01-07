class RenameVotingResultsToCandidateResults < ActiveRecord::Migration
  def change
    rename_table :voting_results, :candidate_results
  end
end

class AddVoteTypesToContestResults < ActiveRecord::Migration
  def change
    add_column :contest_results, :overvotes, :integer
    add_column :contest_results, :undervotes, :integer
  end
end

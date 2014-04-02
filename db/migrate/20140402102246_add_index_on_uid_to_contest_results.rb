class AddIndexOnUidToContestResults < ActiveRecord::Migration
  def change
    add_index :contest_results, :uid
  end
end

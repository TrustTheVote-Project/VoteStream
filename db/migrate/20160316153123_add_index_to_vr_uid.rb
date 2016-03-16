class AddIndexToVrUid < ActiveRecord::Migration
  def change
    add_index :voter_registrations, :uid
  end
end

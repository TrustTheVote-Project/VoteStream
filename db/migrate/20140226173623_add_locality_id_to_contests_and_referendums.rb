class AddLocalityIdToContestsAndReferendums < ActiveRecord::Migration
  def change
    add_column :contests, :locality_id, :integer
    add_column :referendums, :locality_id, :integer
    add_index  :contests, :locality_id
    add_index  :referendums, :locality_id
  end
end

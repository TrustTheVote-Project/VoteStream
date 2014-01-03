class RemoveLocalityIdFromContests < ActiveRecord::Migration

  def up
    remove_column :contests, :locality_id
  end

  def down
    add_column :contests, :locality_id, :integer
    add_index  :contests, :locality_id
  end

end

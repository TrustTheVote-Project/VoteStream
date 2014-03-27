class UpdateIndexUniqueness < ActiveRecord::Migration

  def up
    remove_index :parties, :uid
    add_index    :parties, [ :uid, :locality_id ], unique: true
  end

  def down
    add_index    :parties, :uid, unique: true
    remove_index :parties, [ :uid, :locality_id ], unique: true
  end

end

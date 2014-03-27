class UpdateUniqueIndexesOnDistricts < ActiveRecord::Migration

  def up
    remove_index :districts, :uid
    add_index    :districts, [ :uid, :locality_id ], unique: true
  end

  def down
    add_index    :districts, :uid, unique: true
    remove_index :districts, [ :uid, :locality_id ], unique: true
  end

end

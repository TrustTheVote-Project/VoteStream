class DropAddresses < ActiveRecord::Migration
  def up
    #remove_column :polling_locations, :address_id
  end

  def down
    add_column :polling_locations, :address_id
    add_index  :polling_locations, :address_id, name: "index_polling_locations_on_address_id", using: :btree
  end
end

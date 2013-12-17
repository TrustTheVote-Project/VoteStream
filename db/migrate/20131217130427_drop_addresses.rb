class DropAddresses < ActiveRecord::Migration
  def up
    remove_column :polling_locations, :address_id
    drop_table :addresses
  end

  def down
    create_table :addresses, force: true do |t|
      t.string "line1"
      t.string "line2"
      t.string "city"
      t.string "state"
      t.string "zip"
    end
    add_column :polling_locations, :address_id
    add_index  :polling_locations, :address_id, name: "index_polling_locations_on_address_id", using: :btree
  end
end

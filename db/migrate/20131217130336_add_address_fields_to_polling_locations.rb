class AddAddressFieldsToPollingLocations < ActiveRecord::Migration
  def change
    add_column :polling_locations, :line1, :string
    add_column :polling_locations, :line2, :string
    add_column :polling_locations, :city, :string
    add_column :polling_locations, :state, :string
    add_column :polling_locations, :zip, :string
  end
end

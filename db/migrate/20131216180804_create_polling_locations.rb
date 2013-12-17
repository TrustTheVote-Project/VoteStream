class CreatePollingLocations < ActiveRecord::Migration
  def change
    create_table :polling_locations do |t|
      t.belongs_to  :precinct, index: true
      t.references  :address, index: true
      t.string      :name, null: false
    end
  end
end

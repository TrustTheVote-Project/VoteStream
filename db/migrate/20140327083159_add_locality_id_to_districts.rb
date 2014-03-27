class AddLocalityIdToDistricts < ActiveRecord::Migration
  def change
    add_column :districts, :locality_id, :integer
    add_index  :districts, :locality_id
  end
end

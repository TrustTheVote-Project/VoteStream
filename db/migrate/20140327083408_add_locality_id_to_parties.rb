class AddLocalityIdToParties < ActiveRecord::Migration
  def change
    add_column :parties, :locality_id, :integer
    add_index  :parties, :locality_id
  end
end

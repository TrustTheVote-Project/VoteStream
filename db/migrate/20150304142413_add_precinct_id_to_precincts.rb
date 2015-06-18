class AddPrecinctIdToPrecincts < ActiveRecord::Migration
  def change
    add_column :precincts, :precinct_id, :integer
    add_index :precincts, :precinct_id
  end
  
  
end

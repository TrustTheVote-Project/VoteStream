class CreateDistrictsPrecinctsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :districts, :precincts do |t|
      t.index :district_id
      t.index :precinct_id
    end
  end
end

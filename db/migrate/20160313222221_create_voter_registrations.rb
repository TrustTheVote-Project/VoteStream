class CreateVoterRegistrations < ActiveRecord::Migration
  def change
    create_table :voter_registrations do |t|
      t.references :precinct, index: true #, null: false
      
      t.string :date_of_birth
      t.string :phone
      t.string :race
      t.string :sex
      t.string :party
      t.string :voter_id_type
      t.string :voter_id_value
      t.string :registration_address
      
      t.timestamps
    end
  end
end

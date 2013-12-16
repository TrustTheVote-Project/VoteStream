class CreateElections < ActiveRecord::Migration
  def change
    create_table :elections do |t|
      t.integer :state_id,      null: false
      t.string  :uid,           null: false
      t.date    :held_on
      t.string  :election_type, null: false
      t.boolean :statewide
    end

    add_index :elections, :state_id
    add_index :elections, :uid, unique: true
  end
end

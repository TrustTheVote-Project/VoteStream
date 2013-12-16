class CreateLocalities < ActiveRecord::Migration
  def change
    create_table :localities do |t|
      t.integer :state_id,      null: false
      t.string :name,           null: false
      t.string :locality_type,  null: false
      t.string :uid,            null: false
    end

    add_index :localities, :state_id
    add_index :localities, :uid, unique: true
  end
end

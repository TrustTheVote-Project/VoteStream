class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :uid, null: false
      t.string :code, null: false
      t.string :name
    end

    add_index :states, :uid, unique: true
    add_index :states, :code, unique: true
  end
end

class CreateParties < ActiveRecord::Migration
  def change
    create_table :parties do |t|
      t.string :uid, null: false
      t.integer :sort_order
      t.string :name, null: false
      t.string :abbr, null: false
    end

    add_index :parties, :uid, unique: true
  end
end

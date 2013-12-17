class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.string :uid, null: false
      t.string :name
      t.string :district_type
    end

    add_index :districts, :uid, unique: true
  end
end

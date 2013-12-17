class CreatePrecincts < ActiveRecord::Migration
  def change
    create_table :precincts do |t|
      t.belongs_to :locality, index: true
      t.string :uid, null: false
      t.string :name, null: false
    end

    add_index :precincts, :uid, unique: true
  end
end

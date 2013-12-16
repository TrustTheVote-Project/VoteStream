class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.string      :uid, null: false
      t.belongs_to  :contest, index: true
      t.string      :name
      t.string      :party
      t.integer     :sort_order
    end

    add_index :candidates, :uid, unique: true
  end
end

class CreateContests < ActiveRecord::Migration
  def change
    create_table :contests do |t|
      t.string      :uid, null: false
      t.belongs_to  :locality, index: true
      t.belongs_to  :district, index: true
      t.string      :office
      t.string      :sort_order
    end

    add_index :contests, :uid, unique: true
  end
end

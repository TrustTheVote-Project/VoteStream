class CreateReferendums < ActiveRecord::Migration
  def change
    create_table :referendums do |t|
      t.references  :district, index: true
      t.string      :uid, null: false
      t.string      :title, null: false
      t.text        :subtitle, null: false
      t.text        :question, null: false
      t.string      :sort_order
    end
    add_index :referendums, :uid, unique: true
  end
end

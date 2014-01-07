class CreateBallotResponses < ActiveRecord::Migration
  def change
    create_table :ballot_responses do |t|
      t.references  :referendum, index: true
      t.string      :uid, null: false
      t.string      :name, null: false
      t.integer     :sort_order
    end
    add_index :ballot_responses, :uid, unique: true
  end
end

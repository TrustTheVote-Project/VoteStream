class CreateContestResults < ActiveRecord::Migration
  def change
    create_table :contest_results do |t|
      t.string     :uid, null: false
      t.string     :certification, null: false
      t.references :precinct, index: true, null: false
      t.references :contest, index: true
      t.references :referendum, index: true
      t.integer    :total_votes
      t.integer    :total_valid_votes

      t.timestamps
    end
  end
end

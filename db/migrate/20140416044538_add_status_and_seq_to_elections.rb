class AddStatusAndSeqToElections < ActiveRecord::Migration
  def change
    add_column :elections, :reporting, :decimal, precision: 5, scale: 2, null: false, default: 0
    add_column :elections, :seq, :integer, null: false, default: 0
  end
end

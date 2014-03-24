class AddPartisanWriteinToContests < ActiveRecord::Migration
  def change
    add_column :contests, :partisan, :boolean
    add_column :contests, :write_in, :boolean
  end
end

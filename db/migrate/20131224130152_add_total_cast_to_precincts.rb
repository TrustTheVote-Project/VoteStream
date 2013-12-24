class AddTotalCastToPrecincts < ActiveRecord::Migration
  def change
    add_column :precincts, :total_cast, :integer
  end
end

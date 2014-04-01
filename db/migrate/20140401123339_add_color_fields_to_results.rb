class AddColorFieldsToResults < ActiveRecord::Migration
  def change
    add_column :contest_results, :color_code, :string
  end
end

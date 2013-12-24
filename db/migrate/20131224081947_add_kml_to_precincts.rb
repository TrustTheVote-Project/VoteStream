class AddKmlToPrecincts < ActiveRecord::Migration
  def change
    add_column :precincts, :kml, :text
  end
end

class AddRegVotersToPrecincts < ActiveRecord::Migration
  def change
    add_column :precincts, :registered_voters, :integer
  end
end

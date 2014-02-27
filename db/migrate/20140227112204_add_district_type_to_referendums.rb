class AddDistrictTypeToReferendums < ActiveRecord::Migration
  def change
    add_column :referendums, :district_type, :string
  end
end

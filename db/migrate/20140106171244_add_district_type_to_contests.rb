class AddDistrictTypeToContests < ActiveRecord::Migration
  def change
    add_column :contests, :district_type, :string
    add_index  :contests, :district_type

    Contest.reset_column_information
    Contest.includes(:district).all.each do |c|
      c.district_type = c.district.district_type
      c.save
    end
  end
end

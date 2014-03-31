class DropNotNullsOnReferendumFields < ActiveRecord::Migration
  def change
    change_column_null :referendums, :title, true
    change_column_null :referendums, :subtitle, true
    change_column_null :referendums, :question, true
  end
end

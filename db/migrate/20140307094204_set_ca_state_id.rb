class SetCaStateId < ActiveRecord::Migration
  def change
    State.update_all("uid = '06'", code: 'CA')
  end
end

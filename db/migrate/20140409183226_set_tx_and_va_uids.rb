class SetTxAndVaUids < ActiveRecord::Migration

  def up
    State.where(code: 'TN').update_all(uid: '48')
    State.where(code: 'VA').update_all(uid: '51')
  end

  def down
    State.where(code: 'TN').update_all(uid: nil)
    State.where(code: 'VA').update_all(uid: nil)
  end

end

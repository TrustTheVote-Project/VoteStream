class ReplacePartyWithPartyRefInCandidates < ActiveRecord::Migration

  def up
    add_column    :candidates, :party_id, :integer, null: false
    remove_column :candidates, :party
  end

  def down
    add_column    :candidates, :party, :string
    remove_column :candidates, :party_id
  end

end

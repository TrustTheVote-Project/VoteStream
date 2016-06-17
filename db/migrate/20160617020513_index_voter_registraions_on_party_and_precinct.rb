class IndexVoterRegistraionsOnPartyAndPrecinct < ActiveRecord::Migration
  def change
    add_index :voter_registrations, :party, name: :index_vr_on_party
    add_index :voter_registrations, [:party, :precinct_id], name: :index_vr_on_party_and_precinct
    
  end
end

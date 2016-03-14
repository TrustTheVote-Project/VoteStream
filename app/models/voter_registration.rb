class VoterRegistration < ActiveRecord::Base
  belongs_to :precinct
  has_many :voter_registration_classifications, dependent: :delete_all
end

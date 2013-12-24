class VotingResult < ActiveRecord::Base

  belongs_to :candidate
  belongs_to :precinct

end

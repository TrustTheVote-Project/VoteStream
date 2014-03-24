class BallotResponseResult < ActiveRecord::Base

  belongs_to :contest_result
  belongs_to :ballot_response
  belongs_to :precinct

end

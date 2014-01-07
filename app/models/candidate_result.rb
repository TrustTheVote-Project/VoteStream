class CandidateResult < ActiveRecord::Base

  belongs_to :candidate
  belongs_to :precinct

end

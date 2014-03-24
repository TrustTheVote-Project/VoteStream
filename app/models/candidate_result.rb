class CandidateResult < ActiveRecord::Base

  belongs_to :contest_result
  belongs_to :candidate
  belongs_to :precinct

end

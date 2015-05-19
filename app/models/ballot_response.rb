class BallotResponse < ActiveRecord::Base

  belongs_to :referendum
  has_many :ballot_response_results

  validates :name, presence: true

end

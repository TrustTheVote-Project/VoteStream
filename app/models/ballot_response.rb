class BallotResponse < ActiveRecord::Base

  belongs_to :referendum

  validates :name, presence: true

end

class Election < ActiveRecord::Base

  FEDERAL = "Federal"

  belongs_to :state

  validates :uid, presence: true
  validates :election_type, presence: true

end

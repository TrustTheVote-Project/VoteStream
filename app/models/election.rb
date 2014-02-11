class Election < ActiveRecord::Base

  GENERAL = "general"

  belongs_to :state

  validates :uid, presence: true
  validates :election_type, presence: true

end

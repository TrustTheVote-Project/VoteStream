class Election < ActiveRecord::Base

  GENERAL = "general"

  belongs_to :state
  has_many :contests, :dependent=>:destroy

  validates :uid, presence: true
  validates :election_type, presence: true

end

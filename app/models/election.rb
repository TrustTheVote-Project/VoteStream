class Election < ActiveRecord::Base

  GENERAL = "general"

  belongs_to :state
  has_many :contests, :dependent=>:destroy

  validates :uid, presence: true
  validates :election_type, presence: true


  before_validation :set_election_type
  
  private
  def set_election_type
    if self.election_type.blank?
      self.election_type="TEST"
    end
  end

end

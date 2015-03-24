class Contest < ActiveRecord::Base

  DISTRICT_TYPES = %w( federal state mcd )

  # VSSC District Types:
  # "congressional",
  # "local",
  # "locality",
  # "other",
  # "state-house",
  # "state-senate",
  # "statewide"


  # a hack to isolate locality contests from other localities
  # as we don't have standardized contest UIDs they duplicate on federal and state levels
  belongs_to :locality
  
  # contests won't necessarily have unique IDs between elections
  belongs_to :election

  belongs_to :district
  has_many   :precincts, through: :district
  has_many   :candidates, dependent: :destroy
  has_many   :contest_results, dependent: :destroy

  validates :uid, presence: true
  before_save :set_district_type

  def district_type_normalized
    dt = self.district_type.try(:downcase)
    DISTRICT_TYPES.include?(dt) ? dt : 'other'
  end

  private

  def set_district_type
    self.district_type = self.district.try(:district_type)
  end

end

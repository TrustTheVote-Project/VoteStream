class Contest < ActiveRecord::Base

  DISTRICT_TYPES = %w( federal state mcd )

  # a hack to isolate locality contests from other localities
  # as we don't have standardized contest UIDs they duplicate on federal and state levels
  belongs_to :locality

  belongs_to :district
  has_many   :precincts, through: :district
  has_many   :candidates, dependent: :destroy

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

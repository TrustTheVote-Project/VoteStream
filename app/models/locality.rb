class Locality < ActiveRecord::Base

  COUNTY = "COUNTY"

  belongs_to :state
  has_many   :precincts, dependent: :destroy
  has_many   :districts,   -> { uniq }, through: :precincts
  has_many   :contests,    -> { uniq }, through: :districts
  has_many   :referendums, -> { uniq }, through: :districts

  validates :uid, presence: true
  validates :name, presence: true
  validates :locality_type, presence: true

  def focused_districts
    District.where(id: DataProcessor.focused_district_ids(self))
  end

end

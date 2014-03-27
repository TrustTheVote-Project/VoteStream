class Locality < ActiveRecord::Base

  COUNTY = "COUNTY"

  belongs_to :state
  has_many   :precincts,   dependent: :destroy
  has_many   :districts,   dependent: :delete_all
  has_many   :contests,    dependent: :destroy
  has_many   :referendums, dependent: :destroy
  has_many   :parties,     dependent: :delete_all

  validates :uid, presence: true
  validates :name, presence: true
  validates :locality_type, presence: true

  def focused_districts
    District.where(id: DataProcessor.focused_district_ids(self))
  end

end

class Locality < ActiveRecord::Base

  COUNTY = "COUNTY"

  belongs_to :state
  has_many   :precincts, dependent: :destroy
  has_many   :districts, through: :precincts
  has_many   :contests, through: :districts

  validates :uid, presence: true
  validates :name, presence: true
  validates :locality_type, presence: true

end

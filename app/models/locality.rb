class Locality < ActiveRecord::Base

  COUNTY = "COUNTY"

  belongs_to :state
  has_many   :precincts, dependent: :destroy

  validates :uid, presence: true
  validates :name, presence: true
  validates :locality_type, presence: true

end

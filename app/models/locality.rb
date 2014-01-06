class Locality < ActiveRecord::Base

  COUNTY = "COUNTY"

  belongs_to :state
  has_many   :precincts, dependent: :destroy
  has_many   :districts, -> { uniq }, through: :precincts
  has_many   :contests,  -> { uniq }, through: :districts

  validates :uid, presence: true
  validates :name, presence: true
  validates :locality_type, presence: true

end

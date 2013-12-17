class District < ActiveRecord::Base

  FEDERAL = 'Federal'

  has_and_belongs_to_many :precincts

  validates :uid, presence: true
  validates :name, presence: true
  validates :district_type, presence: true

end

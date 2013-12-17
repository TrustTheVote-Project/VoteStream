class District < ActiveRecord::Base

  belongs_to :state
  has_and_belongs_to_many :precincts

  validates :uid, presence: true
  validates :name, presence: true
  validates :district_type, presence: true

end

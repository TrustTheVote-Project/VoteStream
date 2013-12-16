class District < ActiveRecord::Base

  belongs_to :state

  validates :uid, presence: true
  validates :name, presence: true
  validates :district_type, presence: true

end

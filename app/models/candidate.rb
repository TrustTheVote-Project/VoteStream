class Candidate < ActiveRecord::Base

  belongs_to :contest

  validates :uid, presence: true
  validates :name, presence: true

end

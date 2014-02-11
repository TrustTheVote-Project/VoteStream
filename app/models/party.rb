class Party < ActiveRecord::Base

  validates :name, presence: true
  validates :abbr, presence: true
  validates :uid, uniqueness: true

end

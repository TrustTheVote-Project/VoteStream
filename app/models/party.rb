class Party < ActiveRecord::Base

  validates :name, presence: true
  validates :abbr, presence: true
  validates :uid, uniqueness: { scope: [ :locality_id ] }

end

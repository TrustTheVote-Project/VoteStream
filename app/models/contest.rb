class Contest < ActiveRecord::Base

  belongs_to :locality
  belongs_to :district
  has_many   :candidates, dependent: :destroy

  validates :uid, presence: true

end

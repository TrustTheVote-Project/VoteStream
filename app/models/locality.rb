class Locality < ActiveRecord::Base

  belongs_to :state
  has_many   :contests, dependent: :destroy

  validates :uid, presence: true
  validates :name, presence: true
  validates :locality_type, presence: true

end

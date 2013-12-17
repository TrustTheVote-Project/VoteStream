class State < ActiveRecord::Base

  has_many :elections, dependent: :destroy
  has_many :localities, dependent: :destroy

  validates :code, presence: true
  validates :name, presence: true

end

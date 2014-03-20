class State < ActiveRecord::Base

  has_many :elections, dependent: :destroy
  has_many :localities, dependent: :destroy
  has_many :precincts, through: :localities

  validates :code, presence: true
  validates :name, presence: true

end

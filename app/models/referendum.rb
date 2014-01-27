class Referendum < ActiveRecord::Base

  belongs_to :district
  has_many   :precincts, through: :district
  has_many   :ballot_responses, dependent: :destroy

  validates  :title, presence: true
  validates  :subtitle, presence: true
  validates  :question, presence: true

end

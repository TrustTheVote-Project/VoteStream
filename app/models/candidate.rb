class Candidate < ActiveRecord::Base

  belongs_to :contest
  has_many   :voting_results, dependent: :destroy

  validates :uid, presence: true
  validates :name, presence: true

end

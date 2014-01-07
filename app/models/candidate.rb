class Candidate < ActiveRecord::Base

  belongs_to :contest
  has_many   :candidate_results, dependent: :destroy

  validates :uid, presence: true
  validates :name, presence: true

end

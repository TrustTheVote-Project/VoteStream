class Precinct < ActiveRecord::Base

  belongs_to :locality
  has_and_belongs_to_many :districts
  has_one    :polling_location, dependent: :destroy
  has_many   :candidate_results, dependent: :destroy
  has_many   :ballot_response_results, dependent: :destroy
  has_many   :contests,    -> { uniq }, through: :districts
  has_many   :referendums, -> { uniq }, through: :districts

  validates :uid, presence: true
  validates :name, presence: true

end

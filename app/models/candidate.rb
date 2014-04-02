class Candidate < ActiveRecord::Base

  belongs_to :contest
  belongs_to :party
  has_many   :candidate_results, dependent: :destroy

  validates :uid, presence: true
  validates :name, presence: true

  def party_name
    name =~ /write-?in/i ? "" : party.name
  end

end

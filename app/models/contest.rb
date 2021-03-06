class Contest < ActiveRecord::Base

  DISTRICT_TYPES = %w( federal state mcd )

  # VSSC District Types:
  # "congressional",
  # "local",
  # "locality",
  # "other",
  # "state-house",
  # "state-senate",
  # "statewide"


  # a hack to isolate locality contests from other localities
  # as we don't have standardized contest UIDs they duplicate on federal and state levels
  belongs_to :locality

  # contests won't necessarily have unique IDs between elections
  belongs_to :election

  belongs_to :district
  has_many   :precincts, through: :district
  has_many   :candidates, dependent: :destroy
  has_many   :contest_results, dependent: :destroy
  has_many   :candidate_results, through: :contest_results

  validates :uid, presence: true
  before_save :set_district_type


  def winning_candidates
    candidate_ids = candidate_results.select("candidate_results.candidate_id, sum(candidate_results.votes) as votes").group("candidate_results.candidate_id").order("votes DESC").collect(&:candidate_id)
    candidates_by_id = Candidate.find(candidate_ids).index_by(&:id)
    candidate_ids.collect {|id| candidates_by_id[id] }
  end

  def candidates_by_votes
    cs = {}
    
    contest_results.includes(:candidate_results=>[:candidate]).sum("candidate_results.votes")
    contest_results.includes(:candidate_results=>[:candidate]).each do |cr|
      cr.candidate_results.each do |can_r|
        cs[can_r.candidate] ||= 0
        cs[can_r.candidate] += can_r.votes.to_i
      end
    end
    return cs.to_a.sort {|c1,c2| c2[1]<=>c1[1] }.collect {|c| c[0]}    
  end

  def district_type_normalized
    dt = self.district_type.try(:downcase)
    DISTRICT_TYPES.include?(dt) ? dt : 'other'
  end

  private

  def set_district_type
    self.district_type = self.district.try(:district_type)
  end

end

class Locality < ActiveRecord::Base

  COUNTY = "COUNTY"

  belongs_to :state
  has_many   :precincts,   dependent: :destroy
  has_many   :districts,   dependent: :delete_all
  has_many   :contests,    dependent: :destroy
  has_many   :referendums, dependent: :destroy
  has_many   :parties,     dependent: :delete_all

  validates :uid, presence: true
  validates :name, presence: true
  validates :locality_type, presence: true

  def focused_districts
    District.where(id: DataProcessor.focused_district_ids(self))
  end

  def registrant_count
    precincts.sum(:registered_voters).to_i
  end

  def contest_results
    # [contests, referendums].flatten.each do |refcon|
    #   refcon.contest_results
    # end
    
    # ContestResult.where(precinct_id: precincts.pluck(:id))
    contests.collect {|c| c.contest_results }
  end

  def election_metadata
    contest_votes = []
    stats = []
    contest_results.each do |cr|
      contest_votes << CandidateResult.where(contest_result_id: cr.pluck(:id)).select("ballot_type, sum(votes) as votes").group("candidate_results.ballot_type").order(nil)
    
      stats += cr.select("sum(total_votes) as total_votes, 
          sum(total_valid_votes) as total_valid_votes,
          sum(overvotes) as overvotes,
          sum(undervotes) as undervotes
      ").group("contest_id, referendum_id")
    end
    
    vote_types = {}
    contest_votes.each do |vote_stats|
      vote_stats.each do |vs|
        vote_types[vs.ballot_type] = [vote_types[vs.ballot_type].to_i, vs.votes.to_i].max
      end
    end
    
    
    total_valid_votes = stats.collect {|r| r.total_valid_votes}.max
    total_votes = stats.collect {|r| r.total_votes}.max
    overvotes = stats.collect {|r| r.overvotes}.max
    undervotes = stats.collect {|r| r.undervotes}.max
    return {
      total_valid_votes: total_valid_votes,
      total_votes: total_votes,
      overvotes: overvotes,
      undervotes: undervotes,
      election_day: vote_types["election-day"],
      absentee: vote_types["absentee"],
      early: vote_types["early"],
      registrants: registrant_count
    }
  end

end

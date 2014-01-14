class RefConResults

  def self.data(params)
    if cid = params[:contest_id]
      contest = Contest.find(cid)

      if pid = params[:precinct_id]
        precincts = contest.district.precincts.where(id: pid)
      else
        did = params[:district_id]
        precincts = !did || contest.district_id == did.to_i ? contest.district.precincts : Precinct.none
      end
      cids = contest.candidate_ids
      pids = precincts.map(&:id)
      results = CandidateResult.where(precinct_id: pids, candidate_id: cids)

      candidate_results = results.group('candidate_id').select("sum(votes) v, candidate_id").order('v DESC')
      precincts_results = results.group('candidate_id, precinct_id').select('candidate_id, precinct_id, sum(votes) v').order('v DESC')
      { candidates: Candidate.where(id: cids).select("id, name, party").map { |c| { id: c.id, name: c.name, party: c.party } },
        summary: {
          title:        contest.office,
          total_cast:   precincts.sum(:total_cast),
          total_votes:  results.sum(:votes),
          rows:         candidate_results.map { |r| { cid: r.candidate_id, votes: r.v } }
        },
        precinctResults: precinct_results(precincts_results)
      }
    else
      {}
    end
  end

  def self.precinct_results(res)
    res.group_by(&:precinct_id).map do |precinct_id, results|
      { id:     precinct_id,
        votes:  results.sum(&:v),
        rows:   results[0, 2].map { |r| { cid: r.candidate_id, votes: r.v } }
      }
    end
  end

end

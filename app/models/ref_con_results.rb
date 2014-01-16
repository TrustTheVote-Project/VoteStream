class RefConResults

  def self.data(params)
    if cid = params[:contest_id]
      return contest_data(Contest.find(cid), params)
    elsif rid = params[:referendum_id]
      return referendum_data(Referendum.find(rid), params)
    else
      return {}
    end
  end

  def self.contest_data(contest, params)
    precincts  = precincts_for_refcon(contest, params)
    cids       = contest.candidate_ids
    pids       = precincts.map(&:id)
    candidates = contest.candidates.order(:sort_order)
    results    = CandidateResult.where(precinct_id: pids, candidate_id: cids)

    candidate_votes = results.group('candidate_id').select("sum(votes) v, candidate_id").inject({}) do |m, cr|
      m[cr.candidate_id] = cr.v
      m
    end

    res = {
      summary: {
        title:  contest.office,
        cast:   precincts.sum(:total_cast),
        votes:  results.sum(:votes),
        rows:   candidates.map { |c| { name: c.name, party: c.party, votes: candidate_votes[c.id].to_i } }
      }
    }

    return res
  end

  def self.referendum_data(referendum, params)
    precincts = precincts_for_refcon(referendum, params)
    brids     = referendum.ballot_response_ids
    pids      = precincts.map(&:id)
    responses = referendum.ballot_responses.order(:sort_order)
    results   = BallotResponseResult.where(precinct_id: pids, ballot_response_id: brids)

    response_votes = results.group('ballot_response_id').select("sum(votes) v, ballot_response_id").inject({}) do |m, br|
      m[br.ballot_response_id] = br.v
      m
    end

    res = {
      summary: {
        title:  referendum.title,
        cast:   precincts.sum(:total_cast),
        votes:  results.sum(:votes),
        rows:   responses.map { |r| { name: r.name, votes: response_votes[r.id].to_i } }
      }
    }

    return res
  end

  def self.precinct_results(params)
    if cid = params[:contest_id]
      return contest_precinct_results(Contest.find(cid), params)
    elsif rid = params[:referendum_id]
      return referendum_precinct_results(Referendum.find(rid), params)
    else
      return {}
    end
  end

  def self.contest_precinct_results(contest, params)
    precincts  = precincts_for_refcon(contest, params)
    candidates = contest.candidates
    results    = CandidateResult.where(precinct_id: precincts.map(&:id), candidate_id: contest.candidate_ids)

    rows_candidates = candidates.sort_by(&:sort_order)[0, 2]
    precinct_candidate_results = results.group_by(&:precinct_id).inject({}) do |memo, (pid, results)|
      memo[pid] = results
      memo
    end

    pmap = precincts.map do |p|
      pcr = precinct_candidate_results[p.id] || []
      sorted_pcr = pcr.sort_by(&:votes).reverse
      leader = sorted_pcr.first
      candidate_votes = pcr.inject({}) do |memo, r|
        memo[r.candidate_id] = r.votes
        memo
      end

      { id:           p.id,
        leader:       leader.try(:candidate_id),
        leader_votes: leader.try(:votes),
        votes:        pcr.sum(&:votes),
        rows:         rows_candidates.map { |c| { id: c.id, votes: candidate_votes[c.id] }} }
    end

    return {
      items: candidates.map { |c| { id: c.id, name: c.name, party: c.party } },
      precincts: pmap
    }
  end

  def self.referendum_precinct_results(referendum, params)
    precincts  = precincts_for_refcon(referendum, params)
    responses  = referendum.ballot_responses
    results    = BallotResponseResult.where(precinct_id: precincts.map(&:id), ballot_response_id: referendum.ballot_response_ids)

    precinct_referendum_results = results.group_by(&:precinct_id).inject({}) do |memo, (pid, results)|
      memo[pid] = results
      memo
    end

    pmap = precincts.map do |p|
      pcr = precinct_referendum_results[p.id] || []
      sorted_pcr = pcr.sort_by(&:votes).reverse
      leader = sorted_pcr.first
      response_votes = pcr.inject({}) do |memo, r|
        memo[r.ballot_response_id] = r.votes
        memo
      end

      { id:           p.id,
        leader:       leader.try(:ballot_response_id),
        leader_votes: leader.try(:votes),
        votes:        pcr.sum(&:votes),
        rows:         responses.sort_by(&:sort_order).map { |r| { id: r.id, votes: response_votes[r.id] }} }
    end

    return {
      items: responses.map { |r| { id: r.id, name: r.name } },
      precincts: pmap
    }
  end

  def self.precincts_for_refcon(refcon, params)
    if pid = params[:precinct_id]
      return refcon.district.precincts.where(id: pid)
    else
      did = params[:district_id]
      return !did || refcon.district_id == did.to_i ? refcon.district.precincts : Precinct.none
    end
  end

  # def self.contest_precinct_results(res)
  #   res.group_by(&:precinct_id).map do |precinct_id, results|
  #     { id:     precinct_id,
  #       votes:  results.sum(&:v),
  #       leader: results.sort_by(&:v).last.candidate_id,
  #       rows:   results[0, 2].map { |r| { cid: r.candidate_id, votes: r.v } }
  #     }
  #   end
  # end

  # def self.referendum_precinct_results(res)
  #   res.group_by(&:precinct_id).map do |precinct_id, results|
  #     { id:     precinct_id,
  #       votes:  results.sum(&:v),
  #       leader: results.sort_by(&:v).last.ballot_response_id,
  #       rows:   results[0, 2].map { |r| { rid: r.ballot_response_id, votes: r.v } }
  #     }
  #   end
  # end

end

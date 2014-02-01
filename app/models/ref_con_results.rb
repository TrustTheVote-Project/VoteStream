class RefConResults

  CATEGORY_REFERENDUMS = 'Referendums'

  def initialize(options = {})
    @order_by_votes = (options[:candidate_ordering] || AppConfig[:candidate_ordering]) != 'sort_order'
  end

  def list(params)
    district_ids = districts_for_region(params)

    filt = {}
    filt[:district_id] = district_ids unless district_ids.blank?

    cat = params[:category]
    if cat.blank? || cat == CATEGORY_REFERENDUMS
      referendums = Referendum.where(filt)
    end

    if cat.blank?
      contests = Contest.where(filt)
    elsif cat == CATEGORY_REFERENDUMS
      contests = nil
    else
      contests = Contest.where(filt.merge(district_type: cat))
    end

    list_to_refcons([ contests, referendums ].compact.flatten, params)
  end

  def data(params)
    if cid = params[:contest_id]
      return contest_data(Contest.find(cid), params)
    elsif rid = params[:referendum_id]
      return referendum_data(Referendum.find(rid), params)
    else
      return {}
    end
  end

  def contest_data(contest, params)
    pids       = precinct_ids_for_region(params)
    cids       = contest.candidate_ids
    candidates = contest.candidates
    results    = CandidateResult.where(candidate_id: cids)
    results = results.where(precinct_id: pids) unless pids.blank?

    candidate_votes = results.group('candidate_id').select("sum(votes) v, candidate_id").inject({}) do |m, cr|
      m[cr.candidate_id] = cr.v
      m
    end

    ordered = ordered_records(candidates, candidate_votes) do |i, votes|
      { name: i.name, party: i.party, votes: votes }
    end

    return {
      summary: {
        title:  contest.office,
        votes:  results.sum(:votes),
        rows:   ordered
      }
    }
  end

  def referendum_data(referendum, params)
    pids       = precinct_ids_for_region(params)
    brids     = referendum.ballot_response_ids
    responses = referendum.ballot_responses
    results   = BallotResponseResult.where(ballot_response_id: brids)
    results = results.where(precinct_id: pids) unless pids.blank?

    response_votes = results.group('ballot_response_id').select("sum(votes) v, ballot_response_id").inject({}) do |m, br|
      m[br.ballot_response_id] = br.v
      m
    end

    ordered = ordered_records(responses, response_votes) do |i, votes|
      { name: i.name, votes: votes }
    end

    return {
      summary: {
        title:  referendum.title,
        subtitle: referendum.subtitle,
        text:   referendum.question,
        votes:  results.sum(:votes),
        rows:   ordered
      }
    }
  end

  def precinct_results(params)
    if cid = params[:contest_id]
      return contest_precinct_results(Contest.find(cid), params)
    elsif rid = params[:referendum_id]
      return referendum_precinct_results(Referendum.find(rid), params)
    else
      return {}
    end
  end

  private

  def contest_precinct_results(contest, params)
    precincts  = contest.precincts
    candidates = contest.candidates
    results    = CandidateResult.where(candidate_id: contest.candidate_ids)

    precinct_candidate_results = results.group_by(&:precinct_id).inject({}) do |memo, (pid, results)|
      memo[pid] = results
      memo
    end

    region_pids = precinct_ids_for_region(params)
    pmap = precincts.map do |p|
      pcr = precinct_candidate_results[p.id] || []
      candidate_votes = pcr.inject({}) do |memo, r|
        memo[r.candidate_id] = r.votes
        memo
      end

      ordered = ordered_records(candidates, candidate_votes) do |i, votes|
        { id: i.id, votes: votes }
      end

      li = leader_info(pcr)

      { id:       p.id,
        inRegion: (region_pids && region_pids.include?(p.id)) || false,
        leader:   li[:leader].try(:candidate_id),
        leaderAdvantage: li[:advantage],
        votes:    li[:total_votes],
        rows:     ordered[0, 2] }
    end

    return {
      items: candidates.map { |c| { id: c.id, name: c.name, party: c.party } },
      precincts: pmap
    }
  end

  def referendum_precinct_results(referendum, params)
    precincts  = referendum.precincts
    responses  = referendum.ballot_responses
    results    = BallotResponseResult.where(ballot_response_id: referendum.ballot_response_ids)

    precinct_referendum_results = results.group_by(&:precinct_id).inject({}) do |memo, (pid, results)|
      memo[pid] = results
      memo
    end

    region_pids = precinct_ids_for_region(params)
    pmap = precincts.map do |p|
      pcr = precinct_referendum_results[p.id] || []
      response_votes = pcr.inject({}) do |memo, r|
        memo[r.ballot_response_id] = r.votes
        memo
      end

      ordered = ordered_records(responses, response_votes) do |i, votes|
        { id: i.id, votes: votes }
      end

      li = leader_info(pcr)

      { id:           p.id,
        inRegion:     (region_pids && region_pids.include?(p.id)) || false,
        leader:       li[:leader].try(:ballot_response_id),
        leaderAdvantage: li[:advantage],
        votes:        li[:total_votes],
        rows:         ordered[0, 2] }
    end

    return {
      items: responses.map { |r| { id: r.id, name: r.name } },
      precincts: pmap
    }
  end

  def leader_info(pcr)
    total_votes = pcr.sum(&:votes)

    if total_votes > 0
      pcr_s        = pcr.sort_by(&:votes).reverse
      leader       = pcr_s[0]
      leader_votes = leader.try(:votes).to_i
      runner_votes = pcr_s[1].try(:votes).to_i
      leader_perc  = leader_votes * 100 / total_votes
      runner_perc  = runner_votes * 100 / total_votes
      advantage    = leader_perc - runner_perc
    else
      leader       = nil
      advantage    = 0
    end

    return {
      total_votes: total_votes,
      leader: leader,
      advantage: advantage
    }
  end

  def ordered_records(items, items_votes, &block)
    unordered = items.map do |i|
      votes = items_votes[i.id].to_i
      data = block.call i, votes
      data[:order] = @order_by_votes ? -votes : i.sort_order
      data
    end

    return unordered.sort_by { |cv| cv[:order] }.map { |cv| cv.except(:order) }
  end

  def list_to_refcons(list, params)
    list.map do |rc|
      p = params.merge(no_precinct_results: true)
      if rc.kind_of?(Contest)
        data = contest_data(rc, p)
        data[:type] = 'c'
      else
        data = referendum_data(rc, p)
        data[:type] = 'r'
      end

      data[:id] = rc.id
      data
    end
  end

  # picks districts that are related to the given precinct or the precincts related to the given district
  def districts_for_region(params)
    if (pids = precinct_ids_for_region(params))
      DistrictsPrecinct.where(precinct_id: pids).uniq.pluck("district_id")
    else
      nil
    end
  end

  def precinct_ids_for_region(params)
    if (pid = params[:precinct_id]) || (did = params[:district_id])
      pid ? [ pid.to_i ] : DistrictsPrecinct.where(district_id: did).uniq.pluck("precinct_id")
    else
      nil
    end
  end

end

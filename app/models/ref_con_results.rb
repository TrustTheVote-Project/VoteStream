class RefConResults

  CATEGORY_REFERENDUMS = 'Referendums'
  OVERVOTES_ID = -1
  UNDERVOTES_ID = -1

  def initialize(options = {})
    @order_by_votes = (options[:candidate_ordering] || AppConfig[:candidate_ordering]) != 'sort_order'
  end

  def all_refcons(params)
    locality = Locality.find(params[:locality_id])
    { federal: refcons_of_type(locality, 'Federal', params),
      state:   refcons_of_type(locality, 'State', params),
      mcd:     refcons_of_type(locality, 'MCD', params),
      other:   refcons_of_type(locality, 'Other', params) }
  end

  def refcons_of_type(locality, district_type, params)
    contests     = locality.contests.where(district_type: district_type).select("id, office as name, lpad(sort_order, 5, '0') || lower(office) as sort_order")
    refs         = locality.referendums.where(district_type: district_type).select("id, title as name, lpad(sort_order, 5, '0') || lower(title) as sort_order")

    [ contests, refs ].flatten.sort_by(&:sort_order).map { |i| { id: i.id, name: i.name, type: i.kind_of?(Contest) ? 'c' : 'r' } }
  end

  def region_refcons(params)
    list_to_refcons(refcons_in_region(params), params)
  end

  def contest_data(contest, params)
    pids       = precinct_ids_for_region(params)
    cids       = contest.candidate_ids
    candidates = contest.candidates.includes(:party)
    results    = CandidateResult.where(candidate_id: cids)
    results    = results.where(precinct_id: pids) unless pids.blank?

    candidate_votes = results.group('candidate_id').select("sum(votes) v, candidate_id").inject({}) do |m, cr|
      m[cr.candidate_id] = cr.v
      m
    end

    ballots, overvotes, undervotes, registered = get_vote_stats(contest, pids)

    ordered = ordered_records(candidates, candidate_votes) do |c, votes, idx|
      { name: c.name, party: { name: c.party_name, abbr: c.party.abbr }, votes: votes, c: ColorScheme.candidate_color(c, idx) }
    end


    total = results.sum(:votes)

    ordered << { name: 'Overvotes', party: { name: 'Stats', abbr: 'stats' }, votes: overvotes, c: ColorScheme.special_colors(:overvotes) }
    ordered << { name: 'Undervotes', party: { name: 'Stats', abbr: 'stats' }, votes: undervotes, c: ColorScheme.special_colors(:undervotes) }
    ordered << { name: 'Non-Participating', party: { name: 'Stats', abbr: 'stats' }, votes: registered - ballots, c: ColorScheme.special_colors(:non_participating) }

    return {
      summary: {
        title:         contest.office,
        contest_type:  contest.district_type,
        votes:         total,
        overvotes:     overvotes,
        undervotes:    undervotes,
        ballots:       ballots,
        rows:          ordered
      }
    }
  end

  def get_vote_stats(refcon, pids)
    contest_results = refcon.contest_results
    contest_results = contest_results.where(precinct_id: pids.to_a) unless pids.blank?

    # order(nil) is important as AR adds default order which breaks the SQL query
    r = contest_results.select('sum(overvotes) o, sum(undervotes) u, sum(total_votes) v').order(nil).first
    overvotes  = r.o
    undervotes = r.u
    ballots    = r.v

    registered = Precinct
    registered = registered.where(id: pids.blank? ? refcon.precinct_ids : pids.to_a)

    return ballots, overvotes, undervotes, registered.sum(:registered_voters)
  end

  def referendum_data(referendum, params)
    pids      = precinct_ids_for_region(params)
    brids     = referendum.ballot_response_ids
    responses = referendum.ballot_responses
    results   = BallotResponseResult.where(ballot_response_id: brids)
    results   = results.where(precinct_id: pids) unless pids.blank?

    ballots, overvotes, undervotes, registered = get_vote_stats(referendum, pids)

    response_votes = results.group('ballot_response_id').select("sum(votes) v, ballot_response_id").inject({}) do |m, br|
      m[br.ballot_response_id] = br.v
      m
    end

    ordered = ordered_records(responses, response_votes) do |b, votes, idx|
      { name: b.name, votes: votes, c: ColorScheme.ballot_response_color(b, idx) }
    end

    total = results.sum(:votes)

    ordered << { name: 'Overvotes', party: { name: 'Stats', abbr: 'stats' }, votes: overvotes, c: ColorScheme.special_colors(:overvotes) }
    ordered << { name: 'Undervotes', party: { name: 'Stats', abbr: 'stats' }, votes: undervotes, c: ColorScheme.special_colors(:undervotes) }
    ordered << { name: 'Non-Participating', party: { name: 'Stats', abbr: 'stats' }, votes: registered - ballots, c: ColorScheme.special_colors(:non_participating) }

    return {
      summary: {
        title:       referendum.title,
        subtitle:    referendum.subtitle,
        text:        referendum.question,
        votes:       total,
        overvotes:   overvotes,
        undervotes:  undervotes,
        ballots:     ballots,
        rows:        ordered
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

  def precinct_colors(params)
    region_pids = precinct_ids_for_region(params)
    cid = params[:contest_id]
    rid = params[:referendum_id]
    results = ContestResult.where(contest_id: cid, referendum_id: rid).select("*, precinct_id in (#{(region_pids || [ -1 ]).join(',')}) as inregion")

    # colors for precincts with results
    reported_precinct_ids = []
    colors = results.map do |r|
      reported_precinct_ids << r.precinct_id

      region = r.inregion ? 'i' : 'o'
      code   = r.color_code || 'n0'
      color  = "#{region}#{code}"

      { id: r.precinct_id, c: color }
    end

    # colors for precincts in range
    if cid
      contest = Contest.find(cid)
      pids = contest.precinct_ids
      region_pids ||= Precinct.where(locality_id: contest.locality_id).pluck(:id)
    elsif rid
      referendum = Referendum.find(rid)
      pids = referendum.precinct_ids
      region_pids ||= Precinct.where(locality_id: referendum.locality_id).pluck(:id)
    end

    in_pids  = (pids & region_pids) - reported_precinct_ids
    out_pids = region_pids - pids

    colors = colors + in_pids.map  { |pid| { id: pid, c: "in0" } }
    colors = colors + out_pids.map { |pid| { id: pid, c: "on0" } }

    colors
  end

  # results for the locality
  def election_results_locality(locality, params)
    precincts = locality.precincts.select("id, uid, name")
    cid, rid, caid = election_results_params(params)

    return precincts.map do |precinct|
      election_results_precinct_actual(precinct, cid, rid, caid)
    end
  end

  # results for the single precinct
  def election_results_precinct(precinct, params)
    cid, rid, caid = election_results_params(params)

    [ election_results_precinct_actual(precinct, cid, rid, caid) ]
  end

  private

  def election_results_precinct_actual(precinct, cid, rid, caid)
    results = []

    if !rid || cid || caid
      contest_query = ContestResult.where(precinct_id: precinct.id).joins(:contest, candidate_results: [ :candidate ]).select("certification, total_votes, total_valid_votes, contest_results.uid couid, contests.uid cuid, contests.office cname, candidate_results.uid cruid, votes, candidates.uid cauid, candidates.name caname")
      if caid
        contest_query = contest_query.where(candidate_results: { candidate_id: caid })
      elsif cid
        contest_query = contest_query.where(contest_id: cid)
      end

      contest_query.to_a.group_by(&:couid).each do |contest_result_uid, records|
        res = records.map do |cr|
          { id: cr.cruid, v: cr.votes, cauid: cr.cauid, caname: cr.caname }
        end

        r = records.first
        results << {
          couid: contest_result_uid,
          cert:  r.certification,
          cuid:  r.cuid,
          cname: r.cname,
          tv:    r.total_votes,
          tvv:   r.total_valid_votes,
          r:     res }
      end
    end

    if (!cid && !caid) || rid
      ref_query = ContestResult.where(precinct_id: precinct.id).joins(:referendum, ballot_response_results: [ :ballot_response ]).select("certification, total_votes, total_valid_votes, contest_results.uid couid, referendums.uid ruid, referendums.title rname, ballot_response_results.uid brruid, votes, ballot_responses.uid bruid, ballot_responses.name brname")
      if rid
        ref_query = ref_query.where(referendum_id: rid)
      end

      ref_query.to_a.group_by(&:couid).each do |contest_result_uid, records|
        res = records.map do |rr|
          { id: rr.brruid, v: rr.votes, bruid: rr.bruid, brname: rr.brname }
        end

        r = records.first
        results << {
          couid: contest_result_uid,
          cert:  r.certification,
          ruid:  r.ruid,
          rname: r.rname,
          tv:    r.total_votes,
          tvv:   r.total_valid_votes,
          r:     res }
      end
    end

    { puid: precinct.uid, pname: precinct.name, r: results }
  end

  def contest_precinct_results(contest, params)
    pids       = precinct_ids_for_region(params) || []
    rc_pids    = contest.precinct_pids.uniq && pids
    precincts  = Precinct.select("precincts.id, registered_voters").where(id: rc_pids)

    candidates = contest.candidates.includes(:party)
    results    = CandidateResult.where(candidate_id: contest.candidate_ids)
    results    = results.where(precinct_id: pids) unless pids.blank?

    precinct_candidate_results = results.group_by(&:precinct_id).inject({}) do |memo, (pid, results)|
      memo[pid] = results
      memo
    end

    voters = 0

    pmap = precincts.map do |p|
      voters += p.registered_voters

      pcr = precinct_candidate_results[p.id] || []
      candidate_votes = pcr.inject({}) do |memo, r|
        memo[r.candidate_id] = r.votes
        memo
      end

      ordered = ordered_records(candidates, candidate_votes) do |i, votes, idx|
        { id: i.id, votes: votes }
      end

      li = leader_info(pcr)

      { id:       p.id,
        votes:    li[:total_votes],
        voters:   p.registered_voters,
        rows:     ordered[0, 2] }
    end

    cr = contest.contest_results
    cr = cr.where(precinct_id: pids.to_a) unless pids.blank?
    ballots = cr.sum(:total_votes)

    return {
      items: candidates.map { |c| { id: c.id, name: c.name, party: { name: c.party_name, abbr: c.party.abbr }, c: ColorScheme.candidate_color(c, candidates.index(c)) } },
      ballots: ballots,
      voters:  voters,
      precincts: pmap
    }
  end

  def referendum_precinct_results(referendum, params)
    responses = referendum.ballot_responses
    ids       = referendum.ballot_response_ids
    pids      = precinct_ids_for_region(params) || []
    rc_pids   = referendum.precinct_ids.uniq && pids
    precincts = Precinct.select("precincts.id, registered_voters").where(id: rc_pids)

    results   = BallotResponseResult.where(ballot_response_id: ids, precinct_id: rc_pids)

    precinct_referendum_results = results.group_by(&:precinct_id).inject({}) do |memo, (pid, results)|
      memo[pid] = results
      memo
    end

    voters = 0
    pmap = precincts.map do |p|
      voters += p.registered_voters

      pcr = precinct_referendum_results[p.id] || []
      response_votes = pcr.inject({}) do |memo, r|
        memo[r.ballot_response_id] = r.votes
        memo
      end

      ordered = ordered_records(responses, response_votes) do |i, votes, idx|
        { id: i.id, votes: votes }
      end

      li = leader_info(pcr)

      { id:       p.id,
        votes:    li[:total_votes],
        voters:   p.registered_voters,
        rows:     ordered[0, 2] }
    end

    cr = referendum.contest_results.where(precinct_id: rc_pids)
    ballots = cr.sum(:total_votes)

    return {
      items: responses.map { |r| { id: r.id, name: r.name, c: ColorScheme.ballot_response_color(r, responses.index(r)) } },
      ballots: ballots,
      voters:  voters,
      precincts: pmap
    }
  end

  def leader_info(pcr)
    total_votes = pcr.sum(&:votes)

    if total_votes > 0
      pcr_s        = pcr.sort_by(&:votes).reverse
      leader       = pcr_s[0]
    else
      leader       = nil
    end

    return {
      total_votes: total_votes,
      leader: leader
    }
  end

  def ordered_records(items, items_votes, &block)
    unordered = items.map do |i|
      votes = items_votes[i.id].to_i
      { order: (@order_by_votes ? -votes * 10000 : 0) + i.sort_order.to_i, item: i }
    end

    ordered = unordered.sort_by { |cv| cv[:order] }.map { |cv| cv[:item] }

    idx = 0
    return ordered.map do |i|
      votes = items_votes[i.id].to_i
      data = block.call i, votes, idx
      idx += 1
      data
    end
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
    if !(pids = precinct_ids_for_region(params)).blank?
      DistrictsPrecinct.where(precinct_id: pids).uniq.pluck("district_id")
    else
      nil
    end
  end

  def precinct_ids_for_region(params)
    if (pid = params[:precinct_id]) || (did = params[:district_id])
      pid ? [ pid.to_i ] : DistrictsPrecinct.where(district_id: did).uniq.pluck("precinct_id").to_a
    else
      nil
    end
  end

  def refcons_in_region(params)
    district_ids = districts_for_region(params)

    filt = {}
    if district_ids.blank?
      locality_id = params[:locality_id]
      filt[:locality_id] = locality_id unless locality_id.blank?
    else
      filt[:district_id] = district_ids
    end

    cat = params[:category]
    if cat.blank?
      if contest_id = params[:contest_id]
        contests = Contest.where(filt).where(id: contest_id)
      elsif referendum_id = params[:referendum_id]
        referendums = Referendum.where(filt).where(id: referendum_id)
      else
        contests = Contest.where(filt)
      end
    elsif cat == 'referenda'
      referendums = Referendum.where(filt)
    else
      contests = Contest.where(filt).where(district_type: cat)
      referendums = Referendum.where(filt).where(district_type: cat)
    end

    contests = contests.select("*, lpad(sort_order, 5, '0') || lower(office) as sort_order") if contests
    referendums = referendums.select("*, lpad(sort_order, 5, '0') || lower(title) as sort_order") if referendums

    [ contests, referendums ].compact.flatten.sort_by(&:sort_order)
  end


  def election_results_params(params)
    cuid = params[:contest_id]
    cid  = cuid.blank? ? nil : Contest.find_by!(uid: cuid).id

    ruid = params[:referendum_id]
    rid  = ruid.blank? ? nil : Referendum.find_by!(uid: ruid).id

    cauid = params[:candidate_id]
    caid = cauid.blank? ? nil : Candidate.find_by!(uid: cauid).id

    options = [ cid, rid, caid ]

    raise ApiError.new("Not supported") if options.compact.size > 1

    return options
  end

end

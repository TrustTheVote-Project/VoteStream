class RefConResults

  CATEGORY_REFERENDUMS = 'Referendums'
  OVERVOTES_ID = -1
  UNDERVOTES_ID = -1

  def initialize(options = {})
    @order_by_votes = (options[:candidate_ordering] || AppConfig[:candidate_ordering]) != 'sort_order'
  end

  def all_refcons(params)
    locality = Locality.find(params[:locality_id])
    { "federal"    => refcons_of_type(locality, 'Federal', params),
      "state"      => refcons_of_type(locality, 'State', params),
      "mcd"        => refcons_of_type(locality, 'MCD', params),
      "other"      => refcons_of_type(locality, 'Other', params) }
  end

  def refcons_of_type(locality, district_type, params)
    contests     = locality.contests.where(district_type: district_type).select("id, office as name, lpad(sort_order, 5, '0') || lower(office) as sort_order")
    refs         = locality.referendums.where(district_type: district_type).select("id, title as name, lpad(sort_order, 5, '0') || lower(title) as sort_order")

    [ contests, refs ].flatten.sort_by(&:sort_order).map { |i| { "id" => i.id, "name" => i.name, "type" => i.kind_of?(Contest) ? 'c' : 'r' } }
  end

  def region_refcons(params)
    list_to_refcons(refcons_in_region(params), params)
  end

  def contest_data(contest, params)
    pids       = precinct_ids_for_region(params)
    cids       = contest.candidate_ids
    candidates = contest.candidates.includes(:party)
    results    = set_ballot_type_filters(CandidateResult.where(candidate_id: cids), params)
    results    = results.where(precinct_id: pids) unless pids.blank?


    candidate_votes = results.select("sum(votes) v, candidate_id, ballot_type").group('ballot_type, candidate_id').order(nil).inject({}) do |m, cr|
      m[cr.candidate_id] ||= {}
      m[cr.candidate_id]["total"] ||= 0
      m[cr.candidate_id]["total"] += cr.v.to_i
      m[cr.candidate_id][cr.ballot_type] = cr.v.to_i
      m
    end

    ballots, overvotes, undervotes, registered, channels = get_vote_stats(contest, pids)

    ordered_candidates = contest.winning_candidates

    ordered = ordered_records(candidates, candidate_votes) do |c, votes, vote_channels, idx|
      { 
        "name"  => c.name, 
        "party" => { 
          "name"  => c.party_name, 
          "abbr"  => c.party.abbr 
        }, 
        "votes" => votes,
        "vote_channels" => vote_channels,
        "c" => ColorScheme.candidate_color(c, ordered_candidates.index(c)) 
      }
    end


    ordered << { "name" => 'Overvotes', "party" => { "name" => 'Stats', "abbr" => 'stats' }, "votes" => overvotes, "c" => ColorScheme.special_colors(:overvotes) }
    ordered << { "name" => 'Undervotes', "party" => { "name" => 'Stats', "abbr" => 'stats' }, "votes" => undervotes, "c" => ColorScheme.special_colors(:undervotes) }
    ordered << { "name" => 'Non-Participating', "party" => { "name" => 'Stats', "abbr" => 'stats' }, "np" => true, "votes" => registered - ballots, "c" => ColorScheme.special_colors(:non_participating) }

    return {
      "summary" => {
        "title" =>         contest.office,
        "contest_type"  =>  contest.district_type,
        "votes" =>         ballots - overvotes - undervotes,
        "voters"  =>        registered,
        "overvotes" =>     overvotes,
        "undervotes"  =>    undervotes,
        "ballots" =>       ballots,
        "rows"  =>          ordered
      }
    }
  end

  def get_vote_stats(refcon, pids)
    contest_results = refcon.contest_results
    contest_results = contest_results.where(precinct_id: pids.to_a) unless pids.blank?

    # order(nil) is important as AR adds default order which breaks the SQL query
    r = contest_results.select('sum(overvotes) o, sum(undervotes) u, sum(total_valid_votes) v').order(nil).first
    overvotes  = r.o || 0
    undervotes = r.u || 0
    ballots    = (r.v || 0) + overvotes + undervotes

    candidate_results = CandidateResult.where(contest_result_id: contest_results.pluck(:id))
    br_results = BallotResponseResult.where(contest_result_id: contest_results.pluck(:id))

    type_results = candidate_results.select('ballot_type, sum(votes) v').group(:ballot_type).order(nil)
    channels = type_results.inject({}) {|h,r| h[r.ballot_type] = r.v; h; }

    registered = Precinct
    registered = registered.where(id: pids.blank? ? refcon.precinct_ids : pids.to_a)

    return ballots, overvotes, undervotes, registered.sum(:registered_voters), channels
  end

  def referendum_data(referendum, params)
    pids      = precinct_ids_for_region(params)
    brids     = referendum.ballot_response_ids
    responses = referendum.ballot_responses
    results   = set_ballot_type_filters(BallotResponseResult.where(ballot_response_id: brids), params)
    results   = results.where(precinct_id: pids) unless pids.blank?

    ballots, overvotes, undervotes, registered, channels = get_vote_stats(referendum, pids)

    
    response_votes = results.select("sum(votes) v, ballot_response_id, ballot_type").group('ballot_type, ballot_response_id').order(nil).inject({}) do |m, br|
      m[br.ballot_response_id] ||= {}
      m[br.ballot_response_id]["total"] ||= 0
      m[br.ballot_response_id]["total"] += br.v.to_i
      m[br.ballot_response_id][m] = br.v.to_i
      m
    end

    ordered = ordered_records(responses, response_votes) do |b, votes, vote_channels, idx|
      { "name" => b.name, "votes" => votes, "vote_channels" => vote_channels, "c" => ColorScheme.ballot_response_color(b, idx) }
    end

    ordered << { "name" => 'Overvotes', "party" => { "name" => 'Stats', "abbr" => 'stats' }, "votes" => overvotes, "c" => ColorScheme.special_colors(:overvotes) }
    ordered << { "name" => 'Undervotes', "party" => { "name" => 'Stats', "abbr" => 'stats' }, "votes" => undervotes, "c" => ColorScheme.special_colors(:undervotes) }
    ordered << { "name" => 'Non-Participating', "party" => { "name" => 'Stats', "abbr" => 'stats' }, "votes" => registered - ballots, "c" => ColorScheme.special_colors(:non_participating) }

    return {
      "summary" => {
        "title" =>       referendum.title,
        "subtitle" =>    referendum.subtitle,
        "text" =>        referendum.question,
        "votes" =>       ballots - overvotes - undervotes,
        "overvotes" =>   overvotes,
        "undervotes" =>  undervotes,
        "ballots" =>     ballots,
        "voters" =>      registered,
        "rows" =>        ordered
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

    # r = results.all.detect {|r| r.precinct_id == 51757}
    # raise r.inregion.to_s
    # raise 'a'

    # colors for precincts with results
    reported_precinct_ids = results.map(&:precinct_id)
    precinct_registered_voters = Precinct.where(id: reported_precinct_ids).select("id, registered_voters").inject({}) do |memo, r|
      memo[r.id] = r.registered_voters
      memo
    end

    precinct_registrants = VoterRegistration.where(precinct_id: reported_precinct_ids)
    # TODO: Ignoring 'none' for now since we don't have a lot of party data
    party_counts = precinct_registrants.select("party, precinct_id, count(*)").group(:party, :precinct_id).where("party != 'None'")
    precinct_parties = {}
    party_counts.each do |pc|
      precinct_parties[pc.precinct_id] ||= {}
      precinct_parties[pc.precinct_id][pc.party] = pc.count
    end
    
    colors = results.map do |r|
      region = (r.inregion || region_pids.nil? ) ? 'i' : 'o'
      code   = r.color_code || 'n0'
      color  = "#{region}#{code}"
      
      ballots = r.undervotes + r.overvotes + r.total_valid_votes
      registered = precinct_registered_voters[r.precinct_id] || 0
      participation = case
        when registered <= ballots then 100
        else ballots * 100.0 / registered
      end
      
      party_reg_color = precinct_parties[r.precinct_id] ? registration_color(precinct_parties[r.precinct_id]) : 'n0' 
      
      { 
        "id" => r.precinct_id, 
        "c" => color,  #color shade for contest
        "p" => "#{region}p#{participation_shade(participation)}",  #color shade for participation
        "pr" => "#{region}#{party_reg_color}", #color shade for party registration
        "pp" => participation, 
        "r" => registered, 
        "b" => ballots 
      }
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

    colors = colors + in_pids.map  { |pid| { "id" => pid, "c" => "in0", "p" => "in0", "pr" => "in0" } }
    colors = colors + out_pids.map { |pid| { "id" => pid, "c" => "on0", "p" => "on0", "pr" => "on0" } }

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
          { "id" => cr.cruid, "v" => cr.votes, "cauid" => cr.cauid, "caname" => cr.caname }
        end

        r = records.first
        results << {
          "couid" => contest_result_uid,
          "cert" =>  r.certification,
          "cuid" =>  r.cuid,
          "cname" => r.cname,
          "tv" =>    r.total_votes,
          "tvv" =>   r.total_valid_votes,
          "r" =>     res }
      end
    end

    if (!cid && !caid) || rid
      ref_query = ContestResult.where(precinct_id: precinct.id).joins(:referendum, ballot_response_results: [ :ballot_response ]).select("certification, total_votes, total_valid_votes, contest_results.uid couid, referendums.uid ruid, referendums.title rname, ballot_response_results.uid brruid, votes, ballot_responses.uid bruid, ballot_responses.name brname")
      if rid
        ref_query = ref_query.where(referendum_id: rid)
      end

      ref_query.to_a.group_by(&:couid).each do |contest_result_uid, records|
        res = records.map do |rr|
          { "id" => rr.brruid, "v" => rr.votes, "bruid" => rr.bruid, "brname" => rr.brname }
        end

        r = records.first
        results << {
          "couid" => contest_result_uid,
          "cert" =>  r.certification,
          "ruid" =>  r.ruid,
          "rname" => r.rname,
          "tv"  =>   r.total_votes,
          "tvv" =>   r.total_valid_votes,
          "r" =>     res }
      end
    end

    { "puid" => precinct.uid, "pname" => precinct.name, "r" => results }
  end
  
  def set_ballot_type_filters(query, params)
    ballot_type_filters = [
      ['channel_early', 'early'],
      ['channel_electionday', 'election-day'],
      ['channel_absentee', 'absentee']
    ]
    
    ballot_type_filters.each do |key, row_value|
      # Treat unspecified params as 'true'
      if params.has_key?(key) and params[key].downcase == "false"
        query = query.where.not(ballot_type: row_value)
      end
    end
    
    query
  end
  
  def contest_precinct_results(contest, params)
    Rails.logger.debug("T::#{DateTime.now.strftime('%Q')} Start Contest Precinct results")
    
    pids       = precinct_ids_for_region(params)
    
    rc_pids    = contest.precinct_ids.uniq
    rc_pids    = rc_pids & pids unless pids.nil?
    precincts  = Precinct.select("precincts.id, registered_voters").where(id: rc_pids)

    candidates = contest.candidates.includes(:party)
    Rails.logger.debug("T::#{DateTime.now.strftime('%Q')} Done Initial load")
    
    results    = set_ballot_type_filters(CandidateResult.where(candidate_id: contest.candidate_ids, precinct_id: rc_pids), params)

    
    #grp_only = results.group_by(&:precinct_id)

    Rails.logger.debug("T::#{DateTime.now.strftime('%Q')} Exec Grouping")

    
    results = results.select("SUM(candidate_results.votes) as votes, candidate_results.precinct_id as precinct_id, candidate_results.candidate_id as candidate_id").group("candidate_results.candidate_id, candidate_results.precinct_id")
    precinct_candidate_results = {}
    results.each do |r|
      precinct_candidate_results[r.precinct_id] ||= []
      precinct_candidate_results[r.precinct_id] << r
    end
    
    Rails.logger.debug("T::#{DateTime.now.strftime('%Q')} Done Grouping")
    

    voters = 0

    pmap = precincts.map do |p|
      voters += p.registered_voters || 0

      pcr = precinct_candidate_results[p.id] || []
      candidate_votes = pcr.inject({}) do |memo, r|
        memo[r.candidate_id] ||= { "total" => 0 }
        memo[r.candidate_id]["total"] += r.votes.to_i
        memo
      end

      ordered = ordered_records(candidates, candidate_votes) do |i, votes, vote_channels, idx|
        { "id" => i.id, "votes" => votes, "vote_channels" => vote_channels }
      end

      li = leader_info(pcr)

      { "id" =>       p.id,
        "votes" =>    li["total_votes"],
        "voters" =>   p.registered_voters,
        "rows" =>     ordered[0, 2] }
    end

    Rails.logger.debug("T::#{DateTime.now.strftime('%Q')} Done Total Counts")

    ballots, overvotes, undervotes, registered, channels = get_vote_stats(contest, rc_pids)

    Rails.logger.debug("T::#{DateTime.now.strftime('%Q')} Done Vote Stats")

    ordered_candidates = contest.winning_candidates
    
    Rails.logger.debug("T::#{DateTime.now.strftime('%Q')} Done Winning Candidates")
    
    items = candidates.map { |c,i| { "id" =>  c.id, "name" =>  c.name, "party" =>  { "name" =>  c.party_name, "abbr" =>  c.party.abbr }, "c" =>  ColorScheme.candidate_color(c, ordered_candidates.index(c))} }
    
    Rails.logger.debug("T::#{DateTime.now.strftime('%Q')} Done  calculating items")
    
    return {
      "items" =>      items,
      "ballots" =>    ballots,
      "votes" =>      ballots - overvotes - undervotes,
      "voters" =>     registered,
      "channels" =>   channels,
      "precincts" =>  pmap
    }
  end

  def referendum_precinct_results(referendum, params)
    responses = referendum.ballot_responses
    ids       = referendum.ballot_response_ids
    pids      = precinct_ids_for_region(params)
    rc_pids   = referendum.precinct_ids.uniq
    rc_pids    = rc_pids & pids unless pids.nil?
    precincts = Precinct.select("precincts.id, registered_voters").where(id: rc_pids)

    results   = set_ballot_type_filters(BallotResponseResult.where(ballot_response_id: ids, precinct_id: rc_pids), params)

    precinct_referendum_results = results.group_by(&:precinct_id).inject({}) do |memo, (pid, results)|
      memo[pid] = results
      memo
    end

    voters = 0
    pmap = precincts.map do |p|
      voters += p.registered_voters.to_i

      pcr = precinct_referendum_results[p.id] || []
      response_votes = pcr.inject({}) do |memo, r|
        memo[r.ballot_response_id] ||= { "total"=> 0 }
        memo[r.ballot_response_id]["total"] += r.votes.to_i
        memo
      end

      ordered = ordered_records(responses, response_votes) do |i, votes, vote_channels, idx|
        { "id" => i.id, "votes" => votes, "vote_channels" => vote_channels }
      end

      li = leader_info(pcr)

      { "id"       => p.id,
        "votes"    => li["total_votes"],
        "voters"   => p.registered_voters,
        "rows"     => ordered[0, 2] }
    end

    ballots, overvotes, undervotes, registered, channels = get_vote_stats(referendum, rc_pids)

    

    return {
      "items"      => responses.map { |r| { "id" =>  r.id, "name" =>  r.name, "c" =>  ColorScheme.ballot_response_color(r, responses.index(r)-1) } },
      "ballots"    => ballots,
      "votes"      => ballots - overvotes - undervotes,
      "voters"     => registered,
      "precincts"  => pmap
    }
  end

  def leader_info(pcr)
    total_votes = pcr.collect {|res| res.votes }.compact.sum

    if total_votes > 0
      pcr_s        = pcr.sort{ |a,b| a.votes.to_i <=> b.votes.to_i}.reverse
      leader       = pcr_s[0]
    else
      leader       = nil
    end

    return {
      "total_votes" => total_votes,
      "leader"      => leader
    }
  end

  def ordered_records(items, items_votes_hash, &block)
    unordered = items.map do |i|
      votes = items_votes_hash[i.id] ? items_votes_hash[i.id]["total"].to_i : 0
      { "order" => (@order_by_votes ? -votes * 10000 : 0) + i.sort_order.to_i, "item" => i }
    end

    ordered = unordered.sort_by { |cv| cv["order"] }.map { |cv| cv["item"] }

    idx = 0
    return ordered.map do |i|
      votes = items_votes_hash[i.id] ? items_votes_hash[i.id]["total"].to_i : 0
      vote_channels = items_votes_hash[i.id]
      # if items_votes_hash[i.id]
      #   items_votes_hash[i.id].keys.each do |k|
      #     if k != nil
      #   end
      # end
      data = block.call i, votes, vote_channels, idx
      idx += 1
      data
    end
  end

  def list_to_refcons(list, params)
    list.map do |rc|
      p = params.merge(no_precinct_results: true)
      if rc.kind_of?(Contest)
        data = contest_data(rc, p)
        data["type"] = 'c'
      else
        data = referendum_data(rc, p)
        data["type"] = 'r'
      end

      data["id"] = rc.id
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
    pid = params[:precinct_id]
    pid = [ pid ].flatten.reject {|pid| pid.blank? }.collect(&:to_i)
    did = params[:district_id]
    if (did)
      pid += DistrictsPrecinct.where(district_id: did).uniq.pluck("precinct_id").to_a
    end
    #raise pid.to_s
    pid = pid.uniq
    pid.empty? ? nil : pid
  end

  def refcons_in_region(params)
    district_ids = districts_for_region(params)

    filt = {}
    if district_ids.blank?
      locality_id = params[:locality_id]
      filt["locality_id"] = locality_id unless locality_id.blank?
    else
      filt["district_id"] = district_ids
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

    rir = [ contests, referendums ].compact.flatten.sort_by(&:sort_order)
    rir
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

  def registration_color(hash_of_parties)
    sorted_parties = hash_of_parties.to_a.sort {|ar1, ar2| ar2[1]<=>ar1[1]}
    total = sorted_parties.collect {|a| a[1] }.sum
    if sorted_parties.length > 1
      color = sorted_parties[0][0][0].downcase # just take the first letter
      diff = ((sorted_parties[0][1] - sorted_parties[1][1]) * 100 / total)
      if diff <= AppConfig['map_color']['threshold']['lower']
        shade = 2
      elsif diff <= AppConfig['map_color']['threshold']['upper']
        shade = 1
      else
        shade = 0
      end
      return "#{color}#{shade}"  
    elsif sorted_parties.length == 1
      return "#{sorted_parties[0][0][0].downcase}2"
    else
      return "n2"
    end
  end

  def participation_shade(v)
    if v < 10
      5
    elsif v < 25
      4
    elsif v < 40
      3
    elsif v < 55
      2
    elsif v < 70
      1
    else
      0
    end
  end

end

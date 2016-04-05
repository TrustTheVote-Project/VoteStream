class ElectionFeed

  def initialize(election, filter = {})
    @cids = filter[:cid].nil? ? nil : filter[:cid].split('-').map(&:to_i)
    @rids = filter[:rid].nil? ? nil : filter[:rid].split('-').map(&:to_i)
    @pids = filter[:pid].nil? ? nil : filter[:pid].split('-').map(&:to_i)
    @dids = filter[:did].nil? ? nil : filter[:did].split('-').map(&:to_i)
    @dids.map { |did| @pids += District.find(did).precinct_ids } if @dids
    @pids.uniq! if @pids
    @vmids = filter[:vmid].nil? ? nil : filter[:vmid].split('-')

    @e = election
    localities = election.state.localities
    @l = filter[:lid].present? ? localities.find(filter[:lid]) : localities.first
  end

  def district_ids
    @district_ids ||= (@dids ? @dids : @l.districts.collect(&:id))
    @district_ids
  end

  def precinct_ids
    @precinct_ids ||= (@pids ? @pids : District.find(district_ids).collect {|d| d.precinct_ids }.flatten)
    @precinct_ids
  end

  def contest_ids
    @contest_ids ||= (@cids || [])
    @contest_ids
  end
  def referendum_ids
    @referendum_ids ||= (@rids || [])
    @referendum_ids
  end

  def contest_query(locality)
    query = locality.contests.joins(:district).select("contests.id, contests.uid, office, sort_order, districts.uid duid")
    query.where(contests: { id: contest_ids }) unless contest_ids.blank?
    query
  end

  def referendum_query(locality)
    locality.referendums.joins(:district).select("referendums.id, referendums.uid, title, subtitle, question, sort_order, districts.uid duid")
    return query.where(referendums: { id: referendum_ids }) unless referendum_ids.blank?
  end

end

class ElectionFeed

  def initialize(election, filter = {})
    @cids = filter[:cid].blank? ? [] : filter[:cid].split('-').map(&:to_i)
    @pids = filter[:pid].blank? ? [] : filter[:pid].split('-').map(&:to_i)
    @dids = filter[:did].blank? ? [] : filter[:did].split('-').map(&:to_i)
    @dids.map { |did| @pids += District.find(did).precinct_ids }
    @pids.uniq!

    @e = election
    localities = election.state.localities
    @l = filter[:lid].present? ? localities.find(filter[:lid]) : localities.first
  end

  def contest_query(locality)
    query = locality.contests.joins(:district).select("contests.id, contests.uid, office, sort_order, districts.uid duid")
    return query.where(contests: { id: @cids }) unless @cids.blank?
  end

  def referendum_query(locality)
    locality.referendums.joins(:district).select("referendums.id, referendums.uid, title, subtitle, question, sort_order, districts.uid duid")
  end

end

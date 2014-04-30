class ElectionCsvFeed < ElectionFeed

  attr_reader :locality_name, :state_name, :election_name, :held_on

  def initialize(election, filter)
    super

    @locality_name = @l.name
    @state_name    = @e.state.name
    @election_name = "" # TODO @e.name
    @held_on       = @e.held_on.try(:strftime, '%m/%d/%Y')
  end

  # list of all related precincts
  def precincts
    res = @l.precincts.select("id, uid, name")
    res = res.where(id: @pids) unless @pids.blank?
    res
  end

  def precincts_results(precincts, &block)
    pids = precincts.map(&:id)
    return if pids.blank?

    precinct_names = precincts.inject({}) { |m, p| m[p.id] = p.name; m }
    contest_cond = @cids.blank? ? '' : "AND contest_id IN (#{@cids.join(',')})"

    res = ActiveRecord::Base.connection.exec_query <<-END
      SELECT precinct_id, contest, candidate, party, votes
      FROM results_feed_view
      WHERE precinct_id IN (#{pids.join(',')}) #{contest_cond}
      ORDER BY precinct_id, contest_id, referendum_id, sort_order
    END

    res.each do |r|
      block.call precinct_names[r['precinct_id'].to_i], r['contest'], r['candidate'], r['party'], r['votes']
    end
  end

end

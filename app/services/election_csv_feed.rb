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
      ORDER BY precinct_id, contest_id, referendum_id
    END

    res.each do |r|
      block.call precinct_names[r['precinct_id'].to_i], r['contest'], r['candidate'], r['party'], r['votes']
    end
  end

  # iterator over all related contests in the given precinct
  def contest_results(precinct, &block)
    # query = precinct.contest_results.where('contest_id IS NOT NULL').includes(:contest)
    # query = query.where(contest_id: @cids) unless @cids.blank?
    #
    # query.find_each do |cres|
    #   office = cres.contest.office
    #
    #   cres.candidate_results.includes(candidate: [ :party ]).each do |res|
    #     block.call office, res.candidate.name, res.candidate.party.name, res.votes
    #   end
    #
    #   block.call office, 'OVERVOTES', '', 0
    #   block.call office, 'UNDERVOTES', '', 0
    # end

    res = ActiveRecord::Base.connection.exec_query("SELECT * FROM csv1 WHERE precinct_id=#{precinct.id}")
    res.each do |r|
     block.call r['contest'], r['candidate'], r['party'], r['votes']
    end
  end

  # iterator over all related referendums
  def referendum_results(precinct, &block)
    return unless @cids.blank?

    query = precinct.contest_results.where('referendum_id IS NOT NULL').includes(:referendum)
    query.find_each do |cres|
      name = cres.referendum.title

      cres.ballot_response_results.includes(:ballot_response).each do |res|
        block.call name, res.ballot_response.name, res.votes
      end

      block.call name, 'OVERVOTES', 0
      block.call name, 'UNDERVOTES', 0
    end
  end

end

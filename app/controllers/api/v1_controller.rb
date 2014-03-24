class Api::V1Controller < Api::BaseController

  def elections
    @elections = Election.all
  end

  def election_districts
    @districts = locality.districts
  end

  def election_localities
    raise Api::NotSupported
  end

  def election_ballot_style
    raise Api::NotSupported
  end

  def election_contests
    @contests = locality.contests.includes(candidates: [ :party ])
  end

  def election_referenda
    @referendums = locality.referendums.includes(:ballot_responses)
  end

  # --- Election results ---

  def election_results_precinct
    @precinct = election.state.precincts.find_by!(uid: params[:precinct_uid])
    @results = RefConResults.new.all_precinct_results(@precinct, { candidate_id: params[:candidate_id] })
  end

  private

  def locality
    @locality ||= election.state.localities.first
  end

  def election
    @election ||= Election.find_by(uid: params[:electionUID])
  end

end

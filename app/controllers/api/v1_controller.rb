class Api::V1Controller < Api::BaseController

  INVALID_UID = "Invalid UID"

  rescue_from ActiveRecord::RecordNotFound do
    render json: { errors: [ INVALID_UID ] }
  end

  rescue_from ApiError do |e|
    render json: { errors: [ e.message ] }
  end
  
  def elections
    @elections = Election.all
  end

  def election_districts
    @districts = locality.districts
  end

  def election_localities
    @localities = election.state.localities
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
    @results = RefConResults.new.election_results_precinct(@precinct, params)
  end

  def election_results_locality
    @locality = election.state.localities.find_by!(uid: params[:locality_uid])
    @results  = RefConResults.new.election_results_locality(locality, params)
  end

  private

  def locality
    @locality ||= election.state.localities.first
  end

  def election
    @election ||= Election.find_by!(uid: params[:electionUID])
  end

end

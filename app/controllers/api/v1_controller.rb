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

  private

  def locality
    election = Election.find_by(uid: params[:electionUID])
    election.state.localities.first
  end

end

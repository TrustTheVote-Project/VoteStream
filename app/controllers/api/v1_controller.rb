class Api::V1Controller < Api::BaseController

  INVALID_UID = "Invalid UID"

  rescue_from ActiveRecord::RecordNotFound do
    render json: { errors: [ INVALID_UID ] }
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
    @results = RefConResults.new.all_precinct_results(@precinct, { candidate_id: params[:candidate_id] })
  end

  def election_results_locality
    @locality = election.state.localities.find_by!(uid: params[:locality_uid])
    @precincts = @locality.precincts.select("id, uid, name")

    cuid = params[:contest_id]
    cid  = cuid.blank? ? nil : Contest.find_by!(uid: cuid).id

    ruid = params[:referendum_id]
    rid  = ruid.blank? ? nil : Referendum.find_by!(uid: ruid).id

    cauid = params[:candidate_id]
    caid = cauid.blank? ? nil : Candidate.find_by!(uid: cauid).id

    @results = []
    @precincts.each do |p|
      results = []

      if !rid || cid || caid
        contest_query = ContestResult.where(precinct_id: p.id).joins(:contest, candidate_results: [ :candidate ]).select("contest_results.uid couid, contests.uid cuid, candidate_results.uid cruid, votes, candidates.uid cauid, candidates.name caname")
        if caid
          contest_query = contest_query.where(candidate_results: { candidate_id: caid })
        elsif cid
          contest_query = contest_query.where(contest_id: cid)
        end

        contest_query.to_a.group_by(&:couid).each do |contest_result_uid, records|
          res = records.map do |cr|
            { id: cr.cruid, v: cr.votes, cauid: cr.cauid, caname: cr.caname }
          end

          results << { couid: contest_result_uid, cuid: records.first.try(:cuid), r: res }
        end
      end

      if !cid || rid
        ref_query = ContestResult.where(precinct_id: p.id).joins(:referendum, ballot_response_results: [ :ballot_response ]).select("contest_results.uid couid, referendums.uid ruid, ballot_response_results.uid brruid, votes, ballot_responses.uid bruid, ballot_responses.name brname")
        if rid
          ref_query = ref_query.where(referendum_id: rid)
        end

        ref_query.to_a.group_by(&:couid).each do |contest_result_uid, records|
          res = records.map do |rr|
            { id: rr.brruid, v: rr.votes, bruid: rr.bruid, brname: rr.brname }
          end

          results << { couid: contest_result_uid, ruid: records.first.try(:ruid), r: res }
        end
      end

      @results << { puid: p.uid, pname: p.name, r: results }
    end
  end

  private

  def locality
    @locality ||= election.state.localities.first
  end

  def election
    @election ||= Election.find_by!(uid: params[:electionUID])
  end

end

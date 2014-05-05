class Api::V1Controller < Api::BaseController

  INVALID_UID = "Invalid UID"

  rescue_from ActiveRecord::RecordNotFound do
    respond_to do |format|
      format.json do
        render json: { errors: [ INVALID_UID ] }
      end

      format.xml do
        render text: [ INVALID_UID ].to_xml(root: "errors", skip_types: true)
      end
    end
  end

  rescue_from ApiError do |e|
    respond_to do |format|
      format.json do
        render json: { errors: [ e.message ] }
      end

      format.xml do
        render text: [ e.message ].to_xml(root: "errors", skip_types: true)
      end
    end
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

  # --- Election feed ---

  def election_feed
    render text: ElectionXmlFeed.new(election).render
  end

  def filtered_election_feed
    respond_to do |format|
      format.xml do
        render text: ElectionXmlFeed.new(election, params).render
      end

      format.csv do
        @feed = ElectionCsvFeed.new(election, params)
      end

      format.pdf do
        @feed = ElectionCsvFeed.new(election, params)
        render pdf: 'feed.pdf',
          layout: 'pdf.html',
          show_as_html: params[:debug].present?
      end
    end
  end

  def election_feed_status
    if election.reporting == 100
      fullness = "all"
    elsif election.reporting > 0
      fullness = "partial"
    else
      fullness = "none"
    end

    respond_to do |format|
      format.html { render text: "#{fullness}_unofficial" }
    end
  end

  def election_feed_seq
    respond_to do |format|
      format.html { render text: election.seq }
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

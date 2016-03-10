require 'builder'

class ElectionNistXmlFeed < ElectionFeed

  def initialize(election, filter = {})
    super
  end

  def render
    er = from_locality
    er.to_xml_node.to_xml
  end


  
  def from_locality
    Vedaspace::Parser.instantiate_concrete_classes
    @l
    
    er = ConcreteElectionReport.new
    er.generated_date = DateTime.now
    er.format = Vedaspace::Enum::ReportDetailLevel.summary_contest
    er.status = Vedaspace::Enum::ResultsStatus.pre_election
    er.issuer = @l.name
    er.issuer_abbreviation = @l.state.code
    er.vendor_application_identifier = "VoteStream-v2-<some-deployment-specific-guid>"
    
    er.gp_units ||= []
    District.find(district_ids).each do |d|
      district = ConcreteReportingUnit.new
      district.is_districted = true
      district.reporting_unit_type = d.nist_district_type
      d.precincts.uniq.each do |p|
        district.gp_unit_composing_gp_unit_id_refs ||= []
        if precinct_ids.include?(p.id)
          ref = ConcreteGpUnitComposingGpUnitIdRef.new
          ref.composing_gp_unit_id_ref = p.uid
          district.gp_unit_composing_gp_unit_id_refs << ref
        end
      end
      district.object_id = d.uid
      district.name = d.name
      er.gp_units << district
      
      # TODO: Import external identifiers to votestream to spit back out here
      # district.build_external_identifier_collection
      # district.external_identifier_collection.external_identifiers << Vedastore::ExternalIdentifier.new({
      #   value: d.internal_id,
      #   identifier_type: Vedaspace::Enum::IdentifierType.local_level
      # })
      # district.external_identifier_collection.external_identifiers << Vedastore::ExternalIdentifier.new({
      #   value: d.ocd_id,
      #   identifier_type: Vedaspace::Enum::IdentifierType.ocd_id
      # })
      
    end
    return er
    
    
    # TODO: finish building out hte NIST report
    
    j.reporting_units.each do |ru|
      reporting_unit = Vedastore::ReportingUnit.new

      reporting_unit.object_id = ru.object_id
      reporting_unit.build_external_identifier_collection
      reporting_unit.external_identifier_collection.external_identifiers << Vedastore::ExternalIdentifier.new({
        value: ru.internal_id,
        identifier_type: Vedaspace::Enum::IdentifierType.local_level
      })
      
      reporting_unit.name = ru.name
      reporting_unit.external_identifier_collection.external_identifiers << Vedastore::ExternalIdentifier.new({
        value: ru.ocd_id,
        identifier_type: Vedaspace::Enum::IdentifierType.ocd_id
      })
      
      reporting_unit.reporting_unit_type = Vedaspace::Enum::ReportingUnitType.precinct      
      
      er.gp_units << reporting_unit      
    end
    return er
  end


  private

  def state
    state = @e.state

    @xml.state(id: state.uid) do
      @xml.name state.name
      @xml.abbreviation state.code

      locality @l, state.uid
    end
  end

  def locality(l, state_uid)
    @xml.locality(id: l.uid) do
      @xml.name     l.name
      @xml.state_id state_uid
      @xml.type     l.locality_type

      precincts l
    end
  end

  def electoral_districts(l)
    l.districts.each do |d|
      @xml.electoral_district(id: d.uid) do
        @xml.name d.name
        @xml.type d.district_type
      end
    end
  end

  def parties(l)
    party_uids = {}

    l.parties.each do |p|
      party_uids[p.id] = p.uid
      @xml.party(id: p.uid) do
        @xml.name p.name
        @xml.abbreviation p.abbr
        @xml.sort_order p.sort_order
      end
    end

    party_uids
  end

  def contests(l, party_uids)
    euid = @e.uid

    contest_query(l).each do |c|
      @xml.contest(id: c.uid, iid: c.id) do
        @xml.election_id euid
        @xml.office c.office
        @xml.ballot_placement c.sort_order
        @xml.electoral_district_id c.duid

        candidates(c, party_uids)
        summary_contest_result(c)
      end
    end
  end

  def candidates(c, party_uids)
    c.candidates.each do |ca|
      @xml.candidate(id: ca.uid) do
        @xml.sort_order ca.sort_order
        @xml.party_id   party_uids[ca.party_id]
        @xml.name       ca.name
      end
    end
  end

  def summary_contest_result(c)
    cr = ContestResult.where(contest_id: c.id)
    cr = cr.where(precinct_id: @pids) unless @pids.blank?
    cr = cr.select("sum(total_votes) tv, sum(total_valid_votes) tvv").to_a.first

    @xml.contest_result do
      @xml.contest_id c.uid
      @xml.total_votes cr.tv
      @xml.total_valid_votes cr.tvv

      ca = CandidateResult.joins(:candidate, :contest_result).where(contest_results: { contest_id: c.id })
      ca = ca.where(contest_results: { precinct_id: @pids }) unless @pids.blank?
      ca = ca.select("sum(votes) votes, candidates.uid cauid").group("candidates.uid")

      ca.each do |i|
        @xml.ballot_line_result do
          @xml.candidate_id i.cauid
          @xml.votes i.votes
        end
      end
    end
  end

  def referendums(l)
    return unless @cids.blank?

    referendum_query(l).each do |r|
      @xml.referendum(id: r.uid) do
        @xml.title r.title
        @xml.subtitle r.subtitle
        @xml.text r.question
        @xml.ballot_placement r.sort_order
        @xml.electoral_district_id r.duid

        ballot_responses(r)
        summary_referendum_result(r)
      end
    end
  end

  def ballot_responses(r)
    r.ballot_responses.each do |br|
      @xml.ballot_response(id: br.uid) do
        @xml.text br.name
        @xml.sort_order br.sort_order
      end
    end
  end

  def summary_referendum_result(r)
    cr = ContestResult.where(referendum_id: r.id)
    cr = cr.where(precinct_id: @pids) unless @pids.blank?
    cr = cr.select("sum(total_votes) tv, sum(total_valid_votes) tvv").to_a.first

    @xml.contest_result do
      @xml.referendum_id     r.uid
      @xml.total_votes       cr.tv
      @xml.total_valid_votes cr.tvv

      brs = BallotResponseResult.joins(:ballot_response, :contest_result).where(contest_results: { referendum_id: r.id })
      brs = brs.where(contest_results: { precinct_id: @pids }) unless @pids.blank?
      brs = brs.select("sum(votes) votes, ballot_responses.uid bruid").group("ballot_responses.uid")

      brs.each do |br|
        @xml.ballot_line_result do
          @xml.ballot_response_id br.bruid
          @xml.votes br.votes
        end
      end
    end
  end

  def precincts(l)
    luid = l.uid

    query = l.precincts.includes(:districts, :polling_location)
    query = query.where(precincts: { id: @pids }) unless @pids.blank?
    query.each do |p|
      puid = p.uid

      @xml.precinct(id: puid) do
        @xml.name p.name
        @xml.locality_id luid

        # precinct split
        @xml.precinct_split do
          p.districts.each do |d|
            @xml.electoral_district_id d.uid
          end
        end

        # polling location
        pl = p.polling_location
        if pl
          @xml.polling_location do
            @xml.location_name pl.name
            @xml.line1 pl.line1
            @xml.line2 pl.line2 unless pl.line2.blank?
            @xml.city  pl.city
            @xml.state pl.state
            @xml.zip   pl.zip
          end
        end

        # contests
        crs = p.contest_results.includes(:contest, candidate_results: [ :candidate ])
        if @cids.blank?
          crs = crs.where("contest_id IS NOT NULL")
        else
          crs = crs.where(contest_id: @cids)
        end

        crs.each do |cr|
          @xml.contest_result(id: cr.uid, certification: cr.certification) do
            @xml.contest_id        cr.contest.uid
            @xml.total_votes       cr.total_votes
            @xml.total_valid_votes cr.total_valid_votes

            cr.candidate_results.each do |r|
              @xml.ballot_line_result(id: r.uid, certification: cr.certification) do
                @xml.jurisdiction_id puid
                @xml.candidate_id    r.candidate.uid
                @xml.votes           r.votes
              end
            end
          end
        end

        # referendums
        if @cids.blank?
          crs = p.contest_results.includes(:referendum, ballot_response_results: [ :ballot_response ]).where("referendum_id IS NOT NULL")
          crs.each do |cr|
            @xml.contest_result(id: cr.uid, certification: cr.certification) do
              @xml.referendum_id     cr.referendum.uid
              @xml.total_votes       cr.total_votes
              @xml.total_valid_votes cr.total_valid_votes

              cr.ballot_response_results.each do |r|
                @xml.ballot_line_result(id: r.uid, certification: cr.certification) do
                  @xml.jurisdiction_id puid
                  @xml.ballot_response_id r.ballot_response.uid
                  @xml.votes           r.votes
                end
              end
            end
          end
        end

      end
    end
  end
end

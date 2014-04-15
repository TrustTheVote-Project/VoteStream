require 'builder'

class ElectionFeed

  def initialize(election)
    @e = election
    @xml = Builder::XmlMarkup.new
  end

  def render_xml
    @xml.instruct!
    @xml.vip_object do
      state
    end
  end

  private

  def state
    state = @e.state

    @xml.state(id: state.uid) do
      @xml.name state.name
      @xml.abbreviation state.code

      state.localities.each { |l| locality(l, state.uid) }
    end
  end

  def locality(l, state_uid)
    @xml.locality(id: l.uid) do
      @xml.name     l.name
      @xml.state_id state_uid
      @xml.type     l.locality_type

      electoral_districts(l)
      party_uids = parties(l)
      contests(l, party_uids)
      referendums(l)

      precincts(l)
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

    l.contests.joins(:district).select("contests.id, contests.uid, office, sort_order, districts.uid duid").each do |c|
      @xml.contest(id: c.uid) do
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
    cr = ContestResult.where(contest_id: c.id).select("sum(total_votes) tv, sum(total_valid_votes) tvv").to_a.first
    ca = CandidateResult.joins(:candidate, :contest_result).where(contest_results: { contest_id: c.id }).select("sum(votes) votes, candidates.uid cauid").group("candidates.uid")

    @xml.contest_result do
      @xml.contest_id c.uid
      @xml.total_votes cr.tv
      @xml.total_valid_votes cr.tvv

      ca.each do |i|
        @xml.ballot_line_result do
          @xml.candidate_id i.cauid
          @xml.votes i.votes
        end
      end
    end
  end

  def referendums(l)
    l.referendums.joins(:district).select("referendums.id, referendums.uid, title, subtitle, question, sort_order, districts.uid duid").each do |r|
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
    cr  = ContestResult.where(referendum_id: r.id).select("sum(total_votes) tv, sum(total_valid_votes) tvv").to_a.first
    brs = BallotResponseResult.joins(:ballot_response, :contest_result).where(contest_results: { referendum_id: r.id }).select("sum(votes) votes, ballot_responses.uid bruid").group("ballot_responses.uid")

    @xml.contest_result do
      @xml.referendum_id     r.uid
      @xml.total_votes       cr.tv
      @xml.total_valid_votes cr.tvv

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

    l.precincts.includes(:districts, :polling_location).each do |p|
      puid = p.uid

      @xml.precinct(id: puid) do
        @xml.name p.name
        @xml.locality_id luid

        p.districts.each do |d|
          @xml.electoral_district_id d.uid
        end

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
        crs = p.contest_results.includes(:contest, candidate_results: [ :candidate ]).where("contest_id IS NOT NULL")
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

class DataLoader < BaseLoader

  UNSET                      = "<unset>"
  DISTRICTS_PRECINCT_COLUMNS = [ :district_id, :precinct_id ]
  BALLOT_RESPONSES_COLUMNS   = [ :referendum_id, :name, :sort_order, :uid ]
  DISTRICT_COLUMNS           = [ :name, :district_type, :uid ]
  CANDIDATE_COLUMNS          = [ :name, :party_id, :sort_order, :uid, :color ]

  def initialize(xml_source)
    @xml_source = xml_source
    @doc = Nokogiri::XML(xml_source)
    @doc.remove_namespaces!
    @districts = {}
    @parties = {}
    @nonpartisan_party_uid = nil
    @write_in_party_uid = nil
  end

  def load
    Election.transaction do
      @locality = load_locality

      load_election
      load_districts
      load_precincts
      load_parties
      load_contests
      load_referendums

      DataProcessor.on_definitions_upload
    end
  end

  private

  def load_locality
    state_el = @doc.css("vip_object > state").first
    state = State.find_by(uid: state_el['id'])

    if state
      locality_el = state_el.css("> locality").first
      name = locality_el.css("> name").first.content
      type = locality_el.css("> type").first.content
      uid  = locality_el['id']

      Locality.where(uid: uid).destroy_all

      return Locality.create_with(name: name, locality_type: type, state: state).find_or_create_by(uid: uid)
    else
      raise InvalidFormat.new("State with ID '#{state_el['id']}' was not found")
    end
  end

  def load_election
    election_el = @doc.css("vip_object > election").first

    uid       = election_el['id']
    state_uid = dequote(election_el.css("> state_id").first.content)
    date      = dequote(election_el.css("> date").first.content)
    type      = dequote(election_el.css("> election_type").first.content)
    statewide = dequote(election_el.css("> statewide").first.content).upcase == "YES"

    state = State.find_by_uid(state_uid)
    if state
      state.elections.create_with({
        held_on:        date,
        election_type:  type,
        statewide:      statewide
      }).find_or_create_by(uid: uid)
    else
      raise InvalidFormat.new("State with ID '#{state_uid}' was not found")
    end
  end

  def for_each_state
    @doc.css("vip_object > state").each do |state_el|
      uid = state_el['id']
      state = State.find_by_uid!(uid)
      yield state_el, state
    end
  end

  def for_each_locality
    for_each_state do |state_el, state|
      state_el.css("locality").each do |locality_el|
        uid      = locality_el['id']
        name     = dequote(locality_el.css('> name').first.content).titleize
        type     = dequote(locality_el.css('> type').first.content)

        locality = state.localities.find_by(uid: uid)

        yield locality_el, locality
      end
    end
  end

  def load_precincts
    return if @doc.css('vip_object > state > locality > precinct').size == 0

    for_each_locality do |locality_el, locality|
      locality_el.css('precinct').each do |precinct_el|
        uid      = precinct_el['id']
        name     = dequote(precinct_el.css('> name').first.content)
        kml      = "<MultiGeometry>#{precinct_el.css('Polygon').map { |p| p.to_xml.gsub(/(-?\d+\.\d+,-?\d+\.\d+),-?\d+\.\d+/, '\1') }.join}</MultiGeometry>"

        precinct = locality.precincts.create_with(name: name).find_or_create_by(uid: uid)
        Precinct.where(id: precinct.id).update_all([ "geo = ST_SimplifyPreserveTopology(ST_GeomFromKML(?), 0.0001)", kml ])

        district_precincts = []

        precinct_el.css('electoral_district_id').map { |el| el.content }.uniq.each do |uid|
          district_precincts << [ @districts[uid], precinct.id ]
        end

        DistrictsPrecinct.import DISTRICTS_PRECINCT_COLUMNS, district_precincts

        create_polling_location(precinct_el, precinct)
      end
    end
  end

  def load_districts
    districts = []

    @doc.css('vip_object > electoral_district').each do |district_el|
      name = dequote(district_el.css("> name").first.content)
      type = dequote(district_el.css("> type").first.content)
      districts << [ name, type, district_el['id'] ]
    end

    @locality.districts.import DISTRICT_COLUMNS, districts

    @districts = @locality.districts.all.inject({}) { |m, d| m[d.uid] = d; m }
  end

  def create_polling_location(precinct_el, precinct)
    polling_location_el = precinct_el.css('> polling_location').first
    address_el = polling_location_el.css('> address').first

    precinct.create_polling_location({
      name:  dequote(address_el.css('> location_name').first.content),
      line1: dequote(address_el.css('> line1').first.content),
      line2: dequote(address_el.css('> line2').first.try(:content)),
      city:  dequote(address_el.css('> city').first.content),
      state: dequote(address_el.css('> state').first.content),
      zip:   dequote(address_el.css('> zip').first.content)
    })
  end

  def load_parties
    return if @doc.css('vip_object > party').size == 0

    @doc.css('vip_object > party').each do |party_el|
      uid = party_el['id']
      name = dequote(party_el.css('name').first.content)
      abbr = dequote(party_el.css('abbreviation').first.content)
      sort_order = dequote(party_el.css('sort_order').first.content).to_i

      if name =~ /nonpartisan/i
        @nonpartisan_party_uid = uid
      elsif name =~ /write.*in/i
        @write_in_party_uid = uid
      end

      @locality.parties.create(name: name, abbr: abbr, sort_order: sort_order, uid: uid)
    end

    @parties = {}
    @party_names = {}

    @locality.parties.select('id, uid, name').each do |p|
      @parties[p.uid] = p.id
      @party_names[p.uid] = p.name.downcase
    end

    # Create missing parties
    all_uids = @doc.css('party_id').map { |r| dequote(r.content) }.uniq
    missing_uids = all_uids - @parties.keys
    missing_uids.each do |uid|
      party = @locality.parties.create(name: "Undefined-#{uid}", sort_order: 9999, abbr: 'UNDEF', uid: uid)
      @parties[uid] = party.id
      @party_names[uid] = party.name.downcase
    end
  end

  def load_contests
    return if @doc.css('vip_object > contest').size == 0

    for_each_contest do |contest_el, contest|
      candidates = []

      contest_el.css("candidate").each do |candidate_el|
        uid        = candidate_el['id']
        name       = dequote(candidate_el.css('name, text').first.content)
        party_uid  = dequote(candidate_el.css('> party_id').first.try(:content))
        sort_order = dequote(candidate_el.css('> sort_order').first.content)
        color      = ColorScheme.candidate_pre_color(@party_names[party_uid])
        candidates << [ name, @parties[party_uid], sort_order, uid, color ]
      end

      contest.candidates.import CANDIDATE_COLUMNS, candidates
    end
  end

  def for_each_contest(&block)
    @doc.css("vip_object > contest").each do |contest_el|
      uid         = contest_el['id']
      office      = dequote(contest_el.css("office, title").first.content)
      sort_order  = dequote(contest_el.css("> ballot_placement").first.content)
      district_id = dequote(contest_el.css("> electoral_district_id").first.content)
      district    = @locality.districts.find_by(uid: district_id)
      if district
        parties   = contest_el.css("party_id").map(&:content)
        write_in  = parties.include?(@write_in_party_uid)
        partisan  = !parties.include?(@nonpartisan_party_uid)
        contest   = @locality.contests.create(office: office, sort_order: sort_order, district: district, write_in: write_in, partisan: partisan, uid: uid)
        block.call(contest_el, contest)
      else
        raise_strict InvalidFormat.new("District with ID '#{district_id}' was not found")
      end
    end
  end

  def load_referendums
    return if @doc.css('vip_object > referendum').size == 0

    ballot_responses = []

    for_each_referendum do |referendum_el, referendum|
      referendum_el.css("ballot_response").each do |ballot_response_el|
        uid        = ballot_response_el['id']
        name       = dequote(ballot_response_el.css('> text').first.content)
        sort_order = dequote(ballot_response_el.css('> sort_order').first.content)

        ballot_responses << [ referendum.id, name, sort_order, uid ]
      end
    end

    BallotResponse.import BALLOT_RESPONSES_COLUMNS, ballot_responses
  end

  def for_each_referendum(&block)
    @doc.css("vip_object > referendum").each do |referendum_el|
      uid         = referendum_el['id']
      title       = dequote(referendum_el.css("title").first.content)
      subtitle    = dequote(referendum_el.css("subtitle").first.content)
      subtitle    = UNSET if subtitle.blank?
      question    = dequote(referendum_el.css("text").first.content)
      question    = UNSET if question.blank?
      sort_order  = dequote(referendum_el.css("> ballot_placement").first.content)
      district_id = dequote(referendum_el.css("> electoral_district_id").first.content)
      district    = @locality.districts.find_by(uid: district_id)
      if district
        referendum = @locality.referendums.create(title: title, subtitle: subtitle, question: question, sort_order: sort_order, district: district, district_type: district.district_type, uid: uid)
        block.call(referendum_el, referendum)
      else
        raise_strict InvalidFormat.new("District with ID '#{district_id}' was not found")
      end
    end
  end

end

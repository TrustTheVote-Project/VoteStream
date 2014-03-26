class DataLoader < BaseLoader

  DISTRICTS_PRECINCT_COLUMNS = [ :district_id, :precinct_id ]

  def initialize(xml_source)
    @xml_source = xml_source
    @doc = Nokogiri::XML(xml_source)
    @doc.remove_namespaces!
    @districts = {}
    @nonpartisan_party_uid = nil
    @write_in_party_uid = nil
  end

  def load
    Election.transaction do
      load_locality
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
      Locality.create_with(name: name, locality_type: type, state: state).find_or_create_by(uid: uid)
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
        locality = state.localities.create_with(name: name, locality_type: type).find_or_create_by(uid: uid)

        yield locality_el, locality
      end
    end
  end

  def load_precincts
    return if @doc.css('vip_object > state > locality > precinct').size == 0

    for_each_locality do |locality_el, locality|
      # continue loading precincts
      locality.precincts.destroy_all
      locality_el.css('precinct').each do |precinct_el|
        uid      = precinct_el['id']
        name     = dequote(precinct_el.css('> name').first.content)
        kml      = "<MultiGeometry>#{precinct_el.css('Polygon').map { |p| p.to_xml.gsub(/(-?\d+\.\d+,-?\d+\.\d+),-?\d+\.\d+/, '\1') }.join}</MultiGeometry>"

        precinct = locality.precincts.create_with(name: name).find_or_create_by(uid: uid)
        Precinct.where(id: precinct.id).update_all([ "geo = ST_GeomFromKML(?)", kml ])

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
    @doc.css('vip_object > electoral_district').each do |district_el|
      district = find_or_create_district(district_el)
      @districts[district.uid] = district
    end
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

      Party.create_with(name: name, abbr: abbr, sort_order: sort_order).find_or_create_by(uid: uid)
    end
  end

  def load_contests
    return if @doc.css('vip_object > contest').size == 0

    for_each_contest do |contest_el, contest|
      contest_el.css("candidate").each do |candidate_el|
        uid        = candidate_el['id']
        name       = dequote(candidate_el.css('name, text').first.content)
        party_uid  = dequote(candidate_el.css('> party_id').first.try(:content))
        sort_order = dequote(candidate_el.css('> sort_order').first.content)

        party      = Party.create_with(name: "Undefined", sort_order: 9999, abbr: 'UNDEF').find_or_create_by(uid: party_uid)
        contest.candidates.create_with(name: name, party: party, sort_order: sort_order).find_or_create_by(uid: uid)
      end
    end
  end

  def for_each_contest(&block)
    @doc.css("vip_object > contest").each do |contest_el|
      uid         = contest_el['id']
      office      = dequote(contest_el.css("office, title").first.content)
      sort_order  = dequote(contest_el.css("> ballot_placement").first.content)
      district_id = dequote(contest_el.css("> electoral_district_id").first.content)
      district    = District.find_by_uid(district_id)
      if district
        locality_id = district.precincts.first.locality_id
        parties   = contest_el.css("party_id").map(&:content)
        write_in  = parties.include?(@write_in_party_uid)
        partisan  = !parties.include?(@nonpartisan_party_uid)
        contest   = Contest.create_with(office: office, sort_order: sort_order, district: district, locality_id: locality_id, write_in: write_in, partisan: partisan).find_or_create_by(uid: uid)
        block.call(contest_el, contest)
      else
        raise_strict InvalidFormat.new("District with ID '#{district_id}' was not found")
      end
    end
  end

  def load_referendums
    return if @doc.css('vip_object > referendum').size == 0

    for_each_referendum do |referendum_el, referendum|
      referendum_el.css("ballot_response").each do |ballot_response_el|
        uid        = ballot_response_el['id']
        name       = dequote(ballot_response_el.css('> text').first.content)
        sort_order = dequote(ballot_response_el.css('> sort_order').first.content)

        referendum.ballot_responses.create_with(name: name, sort_order: sort_order).find_or_create_by(uid: uid)
      end
    end
  end

  def for_each_referendum(&block)
    @doc.css("vip_object > referendum").each do |referendum_el|
      uid         = referendum_el['id']
      title       = dequote(referendum_el.css("title").first.content)
      subtitle    = dequote(referendum_el.css("subtitle").first.content)
      question    = dequote(referendum_el.css("text").first.content)
      sort_order  = dequote(referendum_el.css("> ballot_placement").first.content)
      district_id = dequote(referendum_el.css("> electoral_district_id").first.content)
      district    = District.find_by_uid(district_id)
      if district
        locality_id = district.precincts.first.locality_id
        referendum = Referendum.create_with(title: title, subtitle: subtitle, question: question, sort_order: sort_order, district: district, district_type: district.district_type, locality_id: locality_id).find_or_create_by(uid: uid)
        block.call(referendum_el, referendum)
      else
        raise_strict InvalidFormat.new("District with ID '#{district_id}' was not found")
      end
    end
  end

  def find_or_create_district(district_el)
    name = dequote(district_el.css("> name").first.content)
    type = dequote(district_el.css("> type").first.content)
    District.create_with(name: name, district_type: type).find_or_create_by(uid: district_el['id'])
  end

end

class DataLoader < BaseLoader

  DISTRICTS_PRECINCT_COLUMNS  = [ :district_id, :precinct_id ]
  DISTRICTS_PRECINCTS_COLUMNS = [ :district_id ]
  BALLOT_RESPONSES_COLUMNS    = [ :referendum_id, :name, :sort_order, :uid ]
  BALLOT_RESPONSE_COLUMNS     = [ :name, :sort_order, :uid ]
  DISTRICT_COLUMNS            = [ :name, :district_type, :uid ]
  CANDIDATE_COLUMNS           = [ :name, :party_id, :sort_order, :uid, :color ]

  ELECTION                    = 'election'
  DATE                        = 'date'
  ELECTION_TYPE               = 'election_type'
  STATE_ID                    = 'state_id'
  STATEWIDE                   = 'statewide'
  STATE                       = 'state'
  LOCALITY                    = 'locality'
  NAME                        = 'name'
  TYPE                        = 'type'
  PRECINCT                    = 'precinct'
  PRECINCT_SPLIT              = 'precinct_split'
  ELECTORAL_DISTRICT_ID       = 'electoral_district_id'
  POLLING_LOCATION            = 'polling_location'
  ADDRESS                     = 'address'
  LOCATION_NAME               = 'location_name'
  LINE1                       = 'line1'
  LINE2                       = 'line2'
  CITY                        = 'city'
  ZIP                         = 'zip'
  POLYGON                     = 'Polygon'
  GEO_QUERY                   = 'geo = ST_SimplifyPreserveTopology(ST_GeomFromKML(?), 0.0001)'
  MULTI                       = '<MultiGeometry>%s</MultiGeometry>'
  ELECTORAL_DISTRICT          = 'electoral_district'
  PARTY                       = 'party'
  SORT_ORDER                  = 'sort_order'
  ABBREVIATION                = 'abbreviation'
  REFERENDUM                  = 'referendum'
  TITLE                       = 'title'
  SUBTITLE                    = 'subtitle'
  BALLOT_PLACEMENT            = 'ballot_placement'
  BALLOT_RESPONSE             = 'ballot_response'
  TEXT                        = 'text'
  CONTEST                     = 'contest'
  OFFICE                      = 'office'
  CANDIDATE                   = 'candidate'
  PARTY_ID                    = 'party_id'

  attr_reader   :districts, :district_ids
  attr_reader   :parties, :party_ids, :party_names
  attr_accessor :state
  attr_accessor :locality, :locality_uid, :locality_name, :locality_type

  def initialize(xml_source)
    @xml_source = xml_source
  end

  def load
    @districts   = []
    @parties     = []
    @party_ids   = {}
    @party_names = {}

    loader = self

    Election.transaction do
      Xml::Parser.new(Nokogiri::XML::Reader(@xml_source)) do
        loader.parse_election(self)
        loader.parse_districts(self)
        loader.parse_state(self)
        loader.parse_precincts(self)
        loader.parse_parties(self)
        loader.parse_contests(self)
        loader.parse_referendums(self)
      end
    end
  end

  def parse_election(reader)
    loader = self
    reader.for_element ELECTION do
      election = Election.new(uid: attribute('id'))

      inside_element do
        for_element(DATE) { election.held_on = inner_xml }
        for_element(ELECTION_TYPE) { election.election_type = inner_xml }
        for_element(STATE_ID) { election.state = State.find_by(uid: inner_xml) }
        for_element(STATEWIDE) { election.statewide = inner_xml == 'YES' }
      end

      Election.where(uid: election.uid).delete_all
      election.save!
    end
  end

  def parse_state(reader)
    loader = self
    reader.for_element STATE do
      puts "State - #{attribute('id')}"
      loader.state = State.find_by(uid: attribute('id'))

      inside_element do
        loader.parse_locality(self)
      end
    end
  end

  def parse_locality(reader)
    loader = self
    reader.for_element LOCALITY do
      loader.locality_uid  = attribute('id')
      loader.locality_name = loader.locality_type = nil

      inside_element do
        for_element(NAME) { loader.locality_name = inner_xml }
        for_element(TYPE) { loader.locality_type = inner_xml }
      end

      loader.create_locality
    end
  end

  def purge_locality(id)
    locality = Locality.find_by(uid: @locality_uid)
    if locality

      precinct_ids = locality.precinct_ids

      Precinct.where(locality_id: locality.id).delete_all
      Party.where(locality_id: locality.id).delete_all
      District.where(locality_id: locality.id).delete_all

      PollingLocation.where(precinct_id: precinct_ids).delete_all
      DistrictsPrecinct.where(precinct_id: precinct_ids).delete_all

      purge_locality_results(locality)

      Candidate.where(contest_id: locality.contest_ids).delete_all
      Contest.where(locality_id: locality.id).delete_all

      BallotResponse.where(referendum_id: locality.referendum_ids).delete_all
      BallotResponse.where(referendum_id: nil).delete_all
      Referendum.where(locality_id: locality.id).delete_all

      locality.delete
    end
  end

  def create_locality
    puts "Locality: #{@locality_uid} #{@locality_name} #{@locality_type}"

    purge_locality(@locality_uid)

    @locality = Locality.create(name: @locality_name, locality_type: @locality_type, state: @state, uid: @locality_uid)
  end

  def save_districts
    @locality.districts.import DISTRICT_COLUMNS, @districts
    @district_ids = @locality.districts.select('id, uid').inject({}) { |m, d| m[d.uid] = d.id; m }
  end

  def parse_precincts(reader)
    loader = self
    reader.for_element PRECINCT do
      loader.save_districts if loader.district_ids.blank?

      uid              = attribute('id')
      name             = nil
      district_uids    = []
      polling_location = {}
      polygons         = []

      inside_element do
        for_element_text(NAME) { name = value }

        inside_element PRECINCT_SPLIT do
          for_element(ELECTORAL_DISTRICT_ID) { district_uids << inner_xml }
        end

        inside_element POLLING_LOCATION do
          inside_element ADDRESS do
            for_element_text(LOCATION_NAME) { polling_location[:name] = value }
            for_element_text(LINE1)         { polling_location[:line1] = value }
            for_element_text(LINE2)         { polling_location[:line2] = value }
            for_element_text(CITY)          { polling_location[:city] = value }
            for_element_text(STATE)         { polling_location[:state] = value }
            for_element_text(ZIP)           { polling_location[:zip] = value }
          end
        end

        for_element POLYGON do
          polygons << outer_xml.gsub(/(-?\d+\.\d+,-?\d+\.\d+),-?\d+\.\d+/, '\1')
        end
      end

      district_uids.uniq!
      district_ids = district_uids.map { |duid| [ loader.district_ids[duid] ] }

      p = loader.locality.precincts.create(name: name, uid: uid)
      Precinct.where(id: p.id).update_all([ GEO_QUERY, MULTI % polygons.join ])
      p.districts_precincts.import DISTRICTS_PRECINCTS_COLUMNS, district_ids
      p.create_polling_location(polling_location)
    end
  end

  def parse_districts(reader)
    loader = self

    reader.for_element ELECTORAL_DISTRICT do
      district = [ nil, nil, attribute('id') ]

      inside_element do
        for_element_text(NAME) { district[0] = value }
        for_element(TYPE)      { district[1] = inner_xml }
      end

      loader.districts << district
    end
  end

  def parse_parties(reader)
    loader = self
    reader.for_element PARTY do
      raise "No Locality defined yet" unless loader.locality

      uid        = attribute('id')
      name       = nil
      sort_order = nil
      abbr       = nil

      inside_element do
        for_element_text(NAME)    { name = value }
        for_element(SORT_ORDER)   { sort_order = inner_xml }
        for_element(ABBREVIATION) { abbr = inner_xml }
      end

      party = loader.locality.parties.create(uid: uid, name: name, sort_order: sort_order, abbr: abbr)
      loader.party_ids[uid] = party.id
    end
  end

  def parse_referendums(reader)
    loader = self
    reader.for_element REFERENDUM do
      uid              = attribute('id')
      title            = nil
      subtitle         = nil
      question         = nil
      sort_order       = nil
      district_uid     = nil
      ballot_responses = []

      inside_element do
        for_element_text(TITLE)       { title = loader.dequote(value) }
        for_element_text(SUBTITLE)    { subtitle = loader.dequote(value) }
        for_element_text(TEXT)        { question = loader.dequote(value) }
        for_element(BALLOT_PLACEMENT) { sort_order = inner_xml }
        for_element_text(ELECTORAL_DISTRICT_ID) { district_uid = loader.dequote(value) }

        for_element BALLOT_RESPONSE do
          buid = attribute('id')
          btext = nil
          bsort_order = nil

          inside_element do
            for_element(TEXT) { btext = inner_xml }
            for_element(SORT_ORDER) { bsort_order = inner_xml}
          end

          ballot_responses << [ btext, bsort_order, buid ]
        end
      end

      # create referendum
      district_id = loader.district_ids[district_uid]
      referendum = loader.locality.referendums.create!({
        title: title,
        subtitle: subtitle,
        question: question,
        sort_order: sort_order,
        district_id: district_id,
        uid: uid
      })

      # save ballots
      referendum.ballot_responses.import BALLOT_RESPONSE_COLUMNS, ballot_responses
    end
  end

  def parse_contests(reader)
    loader = self
    reader.for_element CONTEST do
      loader.save_districts if loader.district_ids.blank?

      uid          = attribute('id')
      office       = nil
      district_uid = nil
      sort_order   = nil
      candidates   = []

      inside_element do
        for_element_text(OFFICE) { office = loader.dequote(value) }
        for_element_text(ELECTORAL_DISTRICT_ID) { district_uid = loader.dequote(value) }
        for_element(BALLOT_PLACEMENT) { sort_order = inner_xml }

        for_element CANDIDATE do
          cuid        = attribute('id')
          cname       = nil
          cparty_uid  = 'undefined'
          cparty_id   = nil
          csort_order = nil

          inside_element do
            for_element_text(NAME)     { cname = value }
            for_element_text(PARTY_ID) { cparty_uid = value }
            for_element(SORT_ORDER)    { csort_order = inner_xml }
          end

          # convert party UID into party ID or create new one
          cparty_id = loader.party_ids[cparty_uid]
          unless cparty_id
            party = Party.create_undefined(loader.locality, cparty_uid)
            loader.party_ids[cparty_uid]   = party.id
            loader.party_names[cparty_uid] = party.name
            cparty_id = party.id
          end

          color = ColorScheme.candidate_pre_color(loader.party_names[uid])
          candidates << [ cname, cparty_id, csort_order, cuid, color ]
        end
      end

      # create contest
      district_id = loader.district_ids[district_uid]
      write_in = false # TODO fix
      partisan = false # TODO fix
      contest = loader.locality.contests.create(office: office, sort_order: sort_order, district_id: district_id, write_in: write_in, partisan: partisan, uid: uid)

      # save candidates
      contest.candidates.import CANDIDATE_COLUMNS, candidates
    end
  end

end

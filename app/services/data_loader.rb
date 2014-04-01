class DataLoader < BaseLoader

  DISTRICTS_PRECINCT_COLUMNS = [ :district_id, :precinct_id ]
  DISTRICTS_PRECINCTS_COLUMNS = [ :district_id ]
  BALLOT_RESPONSES_COLUMNS   = [ :referendum_id, :name, :sort_order, :uid ]
  BALLOT_RESPONSE_COLUMNS    = [ :name, :sort_order, :uid ]
  DISTRICT_COLUMNS           = [ :name, :district_type, :uid ]
  CANDIDATE_COLUMNS          = [ :name, :party_id, :sort_order, :uid, :color ]

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
        loader.parse_districts(self)
        loader.parse_state(self)
        loader.parse_precincts(self)
        loader.parse_parties(self)
        loader.parse_contests(self)
        loader.parse_referendums(self)
      end
    end
  end

  def parse_state(reader)
    loader = self
    reader.for_element 'state' do
      puts "State - #{attribute('id')}"
      loader.state = State.find_by(uid: attribute('id'))

      inside_element do
        loader.parse_locality(self)
      end
    end
  end

  def parse_locality(reader)
    loader = self
    reader.for_element 'locality' do
      loader.locality_uid  = attribute('id')
      loader.locality_name = loader.locality_type = nil

      inside_element do
        for_element('name') { loader.locality_name = inner_xml }
        for_element('type') { loader.locality_type = inner_xml }
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
    reader.for_element 'precinct' do
      loader.save_districts if loader.district_ids.blank?

      uid              = attribute('id')
      name             = nil
      district_uids    = []
      polling_location = {}
      polygons         = []

      inside_element do
        for_element_text('name') { name = value }

        inside_element 'precinct_split' do
          for_element('electoral_district_id') { district_uids << inner_xml }
        end

        inside_element 'polling_location' do
          for_element_text('location_name') { polling_location[:name] = value }
          for_element_text('line1')         { polling_location[:line1] = value }
          for_element_text('line2')         { polling_location[:line2] = value }
          for_element_text('city')          { polling_location[:city] = value }
          for_element_text('state')         { polling_location[:state] = value }
          for_element_text('zip')           { polling_location[:zip] = value }
        end

        for_element 'Polygon' do
          polygons << outer_xml.gsub(/(-?\d+\.\d+,-?\d+\.\d+),-?\d+\.\d+/, '\1')
        end
      end

      district_uids.uniq!
      district_ids = district_uids.map { |duid| [ loader.district_ids[duid] ] }

      p = loader.locality.precincts.create(name: name, uid: uid)
      Precinct.where(id: p.id).update_all([ "geo = ST_SimplifyPreserveTopology(ST_GeomFromKML(?), 0.0001)", "<MultiGeometry>#{polygons.join}</MultiGeometry>" ])
      p.districts_precincts.import DISTRICTS_PRECINCTS_COLUMNS, district_ids
    end
  end

  def parse_districts(reader)
    loader = self

    reader.for_element 'electoral_district' do
      district = [ nil, nil, attribute('id') ]

      inside_element do
        for_element_text('name') { district[0] = value }
        for_element('type')      { district[1] = inner_xml }
      end

      loader.districts << district
    end
  end

  def parse_parties(reader)
    loader = self
    reader.for_element 'party' do
      raise "No Locality defined yet" unless loader.locality

      uid        = attribute('id')
      name       = nil
      sort_order = nil
      abbr       = nil

      inside_element do
        for_element_text('name')    { name = value }
        for_element('sort_order')   { sort_order = inner_xml }
        for_element('abbreviation') { abbr = inner_xml }
      end

      party = loader.locality.parties.create(uid: uid, name: name, sort_order: sort_order, abbr: abbr)
      loader.party_ids[uid] = party.id
    end
  end

  def parse_referendums(reader)
    loader = self
    reader.for_element 'referendum' do
      uid              = attribute('id')
      title            = nil
      subtitle         = nil
      question         = nil
      sort_order       = nil
      district_uid     = nil
      ballot_responses = []

      inside_element do
        for_element_text('title')       { title = loader.dequote(value) }
        for_element_text('subtitle')    { subtitle = loader.dequote(value) }
        for_element('ballot_placement') { sort_order = inner_xml }
        for_element_text('electoral_district_id') { district_uid = loader.dequote(value) }

        for_element 'ballot_response' do
          buid = attribute('id')
          text = nil
          sort_order = nil

          inside_element do
            for_element('text') { text = inner_xml }
            for_element('sort_order') { sort_order = inner_xml}
          end

          ballot_responses << [ text, sort_order, buid ]
        end
      end

      # create referendum
      district_id = loader.district_ids[district_uid]
      referendum = loader.locality.referendums.create({
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
    reader.for_element 'contest' do
      loader.save_districts if loader.district_ids.blank?

      uid          = attribute('id')
      office       = nil
      district_uid = nil
      sort_order   = nil
      candidates   = []

      inside_element do
        for_element_text('office') { office = loader.dequote(value) }
        for_element_text('electoral_district_id') { district_uid = loader.dequote(value) }
        for_element('sort_order') { sort_order = inner_xml }

        for_element 'candidate' do
          cuid       = attribute('id')
          name       = nil
          party_id   = nil
          sort_order = nil

          inside_element do
            for_element_text('name') { name = value }
            for_element_text('party_id') do
              party_id = loader.party_ids[value]
              unless party_id
                party = Party.create_undefined(loader.locality, value)
                loader.party_ids[value] = party.id
                loader.party_names[value] = party.name
                party_id = party.id
              end
            end
            for_element('sort_order') { sort_order = inner_xml }
          end

          color = ColorScheme.candidate_pre_color(loader.party_names[uid])
          candidates << [ name, party_id, sort_order, cuid, color ]
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

class DataLoader

  def initialize(xml_source)
    @xml_source = xml_source
    @doc = Nokogiri::XML(xml_source)
    @districts = {}
  end

  def load
    load_election
    load_districts
    load_precincts
  end

  private

  def load_election
  end

  def for_each_state
    @doc.css("vip_object > state").each do |state_el|
      uid = state_el['id']
      @state = State.find_by_uid!(uid)

      yield state_el, @state
    end
  end

  def load_precincts
    for_each_state do |state_el, state|
      state_el.css("locality").each do |locality_el|
        uid = locality_el['id']
        name = locality_el.css('> name').first.content.titleize
        type = locality_el.css('> type').first.content
        locality = state.localities.create_with(name: name, locality_type: type).find_or_create_by(uid: uid)

        # continue loading precincts
        locality.precincts.destroy_all
        locality_el.css('precinct').each do |precinct_el|
          uid = precinct_el['id']
          name = dequote(precinct_el.css('> name').first.content)
          precinct = locality.precincts.create_with(name: name).find_or_create_by(uid: uid)

          precinct_el.css('> electoral_district_id').each do |electoral_district_id_el|
            uid = electoral_district_id_el.content
            precinct.districts << @districts[uid]
          end

          create_polling_location(precinct_el, precinct)
        end
      end
    end
  end

  def load_districts
    @doc.css('electoral_district').each do |district_el|
      uid = district_el['id']
      name = district_el.css('> name').first.content
      type = district_el.css('> type').first.content
      district = District.create_with(name: name, district_type: type).find_or_create_by(uid: uid)

      @districts[uid] = district
    end
  end

  def create_polling_location(precinct_el, precinct)
    polling_location_el = precinct_el.css('> polling_location').first
    address_el = polling_location_el.css('> address').first

    precinct.create_polling_location({
      name:  polling_location_el.css('> name').first.content,
      line1: address_el.css('> line1').first.content,
      line2: address_el.css('> line2').first.try(:content),
      city:  address_el.css('> city').first.content,
      state: address_el.css('> state').first.content,
      zip:   address_el.css('> zip').first.content
    })
  end

  def dequote(v)
    v.gsub(/(^["']|["']$)/, '')
  end

end

class DataProcessor

  def self.default_category(locality)
    Rails.cache.fetch("locality:#{locality.id}:default_category") do
      dts = locality.contests.select('DISTINCT contests.district_type').map(&:district_type)
      district_order = [ 'Federal', 'State', 'MCD', 'Other' ]
      (district_order & dts).first || RefConResults::CATEGORY_REFERENDUMS
    end
  end

  def self.percent_reporting(locality)
    v = locality.state.elections.first.reporting
    if v >= 100
      "Final Results"
    elsif v > 0
      "%3.1f" % v + " % Reporting"
    else
      "No Results"
    end
  end

  def self.reporting_precinct_ids(locality)
    stats = precinct_stats(locality)
    stats[:reporting_precinct_ids]
  end

  def self.precinct_stats(locality)
    Rails.cache.fetch("locality:#{locality.id}:precinct_stats") do
      all_pids  = locality.precinct_ids
      reporting = BallotResponseResult.where(precinct_id: all_pids).select("DISTINCT precinct_id").map(&:precinct_id)
      reporting << CandidateResult.where(precinct_id: all_pids).select("DISTINCT precinct_id").map(&:precinct_id)
      reporting = reporting.flatten.uniq

      { precinct_count: all_pids.count,
        reporting_precinct_ids: reporting }
    end
  end

  # returns IDs of districts that doesn't cover whole range of precincts
  def self.focused_district_ids(locality)
    Rails.cache.fetch("locality:#{locality.id}:focused_district_ids") do
      precinct_count = locality.precincts.count
      precinct_ids   = locality.precinct_ids
      DistrictsPrecinct.where(precinct_id: precinct_ids).group("district_id").having("count(*) < #{precinct_count}").pluck(:district_id)
    end
  end
  
  def self.counties_json(locality)
    # SELECT stusps,
    #      ST_Multi(ST_Union(f.the_geom)) as singlegeom
    #    FROM sometable As f
    # GROUP BY stusps
    district_ids = locality.districts.where("name like '%County'").pluck(:id)
    shapes = DistrictsPrecinct.joins(:precinct).where(district_id: district_ids).select("districts_precincts.district_id, ST_AsGeoJSON(ST_Union(precincts.geo)) kml").group("district_id").order(nil)
    # county_shapes = districts.collect do |district|
    #   shape = district.precincts.select("district_id, ST_AsGeoJSON(ST_Union(geo)) kml").group("district_id").order(nil).first
    county_shapes = shapes.collect do |shape|
      {
        "id" => shape.district_id,
        "kml" => JSON.parse(shape.kml)
      }
    end
    return Oj.dump(county_shapes)
  end

  def self.precincts_json(locality)
    t = Time.now
    Rails.cache.fetch("locality:#{locality.id}:precincts") do
      Rails.logger.info(Time.now - t)
      precincts = locality.precincts.where("geo IS NOT NULL").select("id, name, ST_AsGeoJSON(geo) kml, registered_voters").order("name")
      Rails.logger.info(Time.now - t)
      data = precincts.map do |p|
        { "id"=>      p.id,
          "name"=>    p.name,
          "kml"=>     JSON.parse(p.kml),
          #"kml"=>     p.kml
          "voters"=>  p.registered_voters }
      end
      Rails.logger.info("Map data: #{Time.now - t}" )
      json = Oj.dump(data)
      Rails.logger.info("To JSON #{Time.now - t}",)
      return json
    end
  end

  def self.precinct_results_json(params)
    Rails.logger.debug("T::#{DateTime.now.strftime('%Q')} Start DP")
    if params[:contest_id]
      locality_id = Contest.find(params[:contest_id]).locality_id
    else
      locality_id = Referendum.find(params[:referendum_id]).locality_id
    end

    # DEBUG remove this caching
    Rails.cache.fetch("locality:#{locality_id}:#{params.hash}:precinct_results") do
      Rails.logger.debug("T::#{DateTime.now.strftime('%Q')} Inside Cache")
      Oj.dump(RefConResults.new.precinct_results(params))
    end
  end

  def self.precinct_colors_json(params)
    locality_id = params[:locality_id]
    Rails.cache.fetch("locality:#{locality_id}:#{params.hash}:precinct_colors") do
      Oj.dump(RefConResults.new.precinct_colors(params))
    end
  end

  def self.districts_json(locality)
    Rails.cache.fetch("locality:#{locality.id}:districts") do
      districts = locality.focused_districts.order('name')

      order   = %w{ Federal State MCD }
      ordered = districts.sort_by { |d| "#{order.index(d.district_type) || 5}#{d.name.downcase}" }
      data    = ordered.map { |d| { "id" => d.id, "name"=> d.name.titleize, "group"=>(d.district_type || 'other').downcase } }
      Oj.dump(data)
    end
  end

  def self.on_definitions_upload
    flush
  end

  def self.on_results_upload
    flush
  end

  def self.flush
    Rails.cache.delete_matched("locality:*")
  end

end

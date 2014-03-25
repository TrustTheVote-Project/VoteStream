class DataController < ApplicationController

  def districts
    locality  = Locality.find(params[:locality_id])
    districts = locality.focused_districts.includes(:precincts)

    if params[:grouped]
      grouped = districts.group_by(&:district_type)
      @json   = Hash[grouped.map { |t, ds| [ (t || 'other').downcase, ds.map { |d| { id: d.id, name: d.name.titleize } } ] }]
    else
      order   = %w{ Federal State MCD }
      ordered = districts.sort_by { |d| "#{order.index(d.district_type) || 5}#{d.name.downcase}" }
      @json   = ordered.map { |d| { id: d.id, name: d.name.titleize, pids: d.precinct_ids } }
    end

    render json: @json
  end

  def precincts
    locality  = Locality.find(params[:locality_id])
    tolerance = 0.001
    precincts = locality.precincts.select("id, name, ST_AsGeoJSON(ST_SimplifyPreserveTopology(geo, #{tolerance})) json")
    render json: precincts.map { |p| { id: p.id, name: p.name, kml: JSON.parse(p.json) } }
  end

  def precincts_geometries
    locality = Locality.find(params[:locality_id])
    render json: locality.precincts.map { |p| { id: p.id, kml: p.kml } }
  end

  # the list of all refcons grouped
  def all_refcons
    render json: RefConResults.new.all_refcons(params)
  end

  # the list of all referendums and contests in the given locality+region
  def region_refcons
    render json: RefConResults.new.region_refcons(params)
  end

  # election results for the given precinct
  def precinct_results
    render json: RefConResults.new.precinct_results(params)
  end

  # def results
  #   render json: RefConResults.new.data(params)
  # end

  def voting_results
    locality = Locality.find(params[:locality_id])
    precincts = locality.precincts
    render json: precincts.map { |p| { id: p.id, name: p.name } }
  end

end

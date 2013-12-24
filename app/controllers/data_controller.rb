class DataController < ApplicationController

  def districts
    contest = Contest.find(params[:contest_id])
    districts = [ contest.district ]
    render json: districts.map { |d| { id: d.id, name: d.name } }
  end

  def precincts
    contest = Contest.find(params[:contest_id])
    precincts = contest.district.precincts
    render json: precincts.map { |p| { id: p.id, name: p.name } }
  end

  def precincts_geometries
    locality = Locality.find(params[:locality_id])
    render json: locality.precincts.map { |p| { id: p.id, kml: p.kml } }
  end

end

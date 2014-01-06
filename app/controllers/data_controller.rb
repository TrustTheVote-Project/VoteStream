class DataController < ApplicationController

  def districts
    contest_id = params[:contest_id]
    if contest_id.present?
      contest   = Contest.find(contest_id)
      districts = [ contest.district ]
    else
      locality  = Locality.find(params[:locality_id])
      districts = locality.districts
    end

    render json: districts.map { |d| { id: d.id, name: d.name } }
  end

  def precincts
    contest_id = params[:contest_id]
    if contest_id.present?
      contest   = Contest.find(contest_id)
      precincts = contest.district.precincts
    else
      locality  = Locality.find(params[:locality_id])
      precincts = locality.precincts
    end

    render json: precincts.map { |p| { id: p.id, name: p.name } }
  end

  def precincts_geometries
    locality = Locality.find(params[:locality_id])
    render json: locality.precincts.map { |p| { id: p.id, kml: p.kml } }
  end

  def voting_results
    contest = Contest.find(params[:contest_id])
    precincts = contest.district.precincts
    precincts = precincts.joins(:districts).where(districts: { id: params[:district_id] }) if params[:district_id].present?
    precincts = precincts.where(id: params[:precinct_id]) if params[:precinct_id].present?

    render json: precincts.map { |p| { id: p.id, name: p.name } }
  end

end

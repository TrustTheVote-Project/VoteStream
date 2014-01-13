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

    districts = districts.includes(:precincts)
    render json: districts.map { |d| { id: d.id, name: d.name, pids: d.precinct_ids } }
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

    render json: precincts.map { |p| { id: p.id, name: p.name, kml: p.kml } }
  end

  def precincts_geometries
    locality = Locality.find(params[:locality_id])
    render json: locality.precincts.map { |p| { id: p.id, kml: p.kml } }
  end

  # the list of all referendums and contests in the given locality+region
  def refcons
    if (pid = params[:precinct_id]) || (did = params[:district_id])
      region = pid ? Precinct.find(pid) : District.find(did)
      contests = region.contests
      referendums = region.referendums
    else
      locality = Locality.find(params[:locality_id])
      contests = locality.contests
      referendums = locality.referendums
    end

    render json: list_to_refcons([ contests, referendums ].compact.flatten)
  end

  def results
    render json: RefConResults.data(params)
  end

  def voting_results
    locality = Locality.find(params[:locality_id])
    precincts = locality.precincts
    render json: precincts.map { |p| { id: p.id, name: p.name } }
  end

  private

  def list_to_refcons(list)
    list.map do |rc|
      { type: rc.kind_of?(Contest) ? 'contest' : 'referendum', id: rc.id }
    end
  end

end

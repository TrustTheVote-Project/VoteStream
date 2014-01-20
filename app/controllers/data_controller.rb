class DataController < ApplicationController

  CATEGORY_REFERENDUMS = 'Referendums'

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
    else
      region = Locality.find(params[:locality_id])
    end

    cat = params[:category]
    if cat.blank? || cat == CATEGORY_REFERENDUMS
      referendums = region.referendums
    end

    if cat.blank?
      contests = region.contests
    elsif cat == CATEGORY_REFERENDUMS
      contests = nil
    else
      contests = region.contests.where(district_type: cat)
    end

    render json: list_to_refcons([ contests, referendums ].compact.flatten)
  end

  def precinct_results
    render json: RefConResults.new.precinct_results(params)
  end

  def results
    render json: RefConResults.new.data(params)
  end

  def voting_results
    locality = Locality.find(params[:locality_id])
    precincts = locality.precincts
    render json: precincts.map { |p| { id: p.id, name: p.name } }
  end

  private

  def list_to_refcons(list)
    list.map do |rc|
      p = params.merge(no_precinct_results: true)
      if rc.kind_of?(Contest)
        data = RefConResults.new.contest_data(rc, p)
        data[:type] = 'c'
      else
        data = RefConResults.new.referendum_data(rc, p)
        data[:type] = 'r'
      end

      data[:id] = rc.id
      data
    end
  end

end

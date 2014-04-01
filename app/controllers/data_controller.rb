class DataController < ApplicationController

  before_filter :conditional_flush

  def districts
    locality  = Locality.find(params[:locality_id])
    render text: DataProcessor.districts_json(locality, params[:grouped])
  end

  def precincts
    locality = Locality.find(params[:locality_id])
    render text: DataProcessor.precincts_json(locality)
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
    render text: DataProcessor.precinct_results_json(params)
  end

  def voting_results
    locality = Locality.find(params[:locality_id])
    precincts = locality.precincts
    render json: precincts.map { |p| { id: p.id, name: p.name } }
  end

  private

  def conditional_flush
    DataProcessor.flush if params[:flush_cache]
  end

end

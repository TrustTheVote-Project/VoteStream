class DataController < ApplicationController

  before_filter :conditional_flush

  def districts
    locality  = Locality.find(params[:locality_id])
    render text: DataProcessor.districts_json(locality)
  end

  def precincts
    locality = Locality.find(params[:locality_id])
    precincts_json = DataProcessor.precincts_json(locality)
    render text: precincts_json
  end

  def counties
    locality = Locality.find(params[:locality_id])
    counties_json = DataProcessor.counties_json(locality)
    render text: counties_json
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

  # quick summary of colors for all precincts
  def precinct_colors
    render text: DataProcessor.precinct_colors_json(params)
  end

  def voting_results
    locality = Locality.find(params[:locality_id])
    precincts = locality.precincts
    render json: precincts.map { |p| { id: p.id, name: p.name } }
  end
  
  def election_metadata
    locality_id = params[:locality_id]
    election_metadata = Rails.cache.fetch("locality:#{locality_id}:#{params.hash}:metadata") do
      locality = Locality.find(locality_id)
      Oj.dump(locality.election_metadata)
    end
    render json: election_metadata
  end
  

  private

  def conditional_flush
    DataProcessor.flush if params[:flush]
  end

end

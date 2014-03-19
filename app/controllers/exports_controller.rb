class ExportsController < ApplicationController

  def index
    locality     = Locality.find(params[:lid])
    election     = locality.state.elections.first
    contest_ids  = params[:cid].to_s.split('-')
    district_ids = params[:did].to_s.split('-')
    precinct_ids = params[:pid].to_s.split('-')

    @filename = "#{locality.name.titleize.gsub(/[^a-z]/i, '')}#{election.held_on.strftime('%Y%m%d')}.#{params[:format]}"

    respond_to do |format|
      format.csv
      format.xml
      format.pdf do
        render text: 'test'
      end
    end
  end

end

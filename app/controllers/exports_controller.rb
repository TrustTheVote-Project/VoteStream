class ExportsController < ApplicationController

  def index
    locality     = Locality.find(params[:lid])
    contest_ids  = params[:cid].to_s.split('-')
    district_ids = params[:did].to_s.split('-')
    precinct_ids = params[:pid].to_s.split('-')

    @filename = "test.#{params[:format]}"

    respond_to do |format|
      format.csv
      format.xml
      format.pdf do
        render text: 'test'
      end
    end
  end

end

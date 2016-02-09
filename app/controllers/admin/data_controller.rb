class Admin::DataController < Admin::BaseController

  before_filter :requires_file, only: [ :load_definitions, :load_results ]

  def index
  end

  def full_reset
    Election.delete_all
    Locality.delete_all
    Contest.delete_all
    Candidate.delete_all
    CandidateResult.delete_all
    Referendum.delete_all
    BallotResponse.delete_all
    BallotResponseResult.delete_all
    ContestResult.delete_all
    Precinct.delete_all
    District.delete_all
    DistrictsPrecinct.delete_all
    Party.delete_all
    PollingLocation.delete_all
    ColorScheme.delete_all

    redirect_to :admin_data, notice: "Data has been reset"
  end

  def load_definitions
    contents = params[:file].read
    doc = Nokogiri::XML(contents) { |config| config.noblanks }
    if doc.root.name == "ElectionReport"
      NistErrLoader.new(contents).load
    else
      DataLoader.new(contents).load
    end
      redirect_to :admin_data, notice: "Definitions have been uploaded"
  end
  
  def load_results
    ResultsLoader.new(params[:file]).load
    redirect_to :admin_data, notice: "Results have been uploaded"
  end

  def load_vssc
    mismatches = NistErrLoader.new(params[:file]).load(params[:locality_id])
    if !mismatches.empty?
      raise mismatches.to_s
    end
    redirect_to :admin_data, notice: "Definitioins have been uploaded"    
  end
  
  def load_vssc_results
    mismatches = NistErrLoader.new(params[:file]).load_results(params[:locality_id])    
    if !mismatches.empty?
      raise mismatches.to_s
    end
    redirect_to admin_locality_path(params[:locality_id]), notice: "Results have been uploaded"    
  end


  private

  def requires_file
    if params[:file].blank?
      redirect_to :admin_data, alert: "Please choose the file to upload"
    end
  end

end

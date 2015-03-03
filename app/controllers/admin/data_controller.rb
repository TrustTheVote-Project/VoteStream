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
    Precinct.destroy_all
    District.delete_all

    redirect_to :admin_data, notice: "Data has been reset"
  end

  def load_definitions
    DataLoader.new(params[:file]).load
    redirect_to :admin_data, notice: "Definitioins have been uploaded"
  end
  
  def load_vssc
    VSSCLoader.new(params[:file]).load
    redirect_to :admin_data, notice: "Definitioins have been uploaded"    
  end

  def load_results
    ResultsLoader.new(params[:file]).load
    redirect_to :admin_data, notice: "Results has been uploaded"
  end

  private

  def requires_file
    if params[:file].blank?
      redirect_to :admin_data, alert: "Please choose the file to upload"
    end
  end

end

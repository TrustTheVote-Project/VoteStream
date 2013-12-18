class Admin::DataController < Admin::BaseController

  def index
  end

  def load_definitions
    if params[:file].blank?
      redirect_to :admin_data, alert: "Please choose the file to upload"
      return
    end

    DataLoader.new(params[:file]).load
    redirect_to :admin_data, notice: "Data has been uploaded"
  end

end

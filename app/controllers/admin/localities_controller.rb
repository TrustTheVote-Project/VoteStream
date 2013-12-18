class Admin::LocalitiesController < Admin::BaseController

  def index
    @localities = Locality.joins(:state).order("states.name, localities.name").all
  end

  def show
    @locality = Locality.find(params[:id])
  end

end

class Admin::StatesController < Admin::BaseController

  def index
    @states = State.order('code').all
  end

  def show
    @state = State.find(params[:id])
  end

end

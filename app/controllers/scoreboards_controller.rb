class ScoreboardsController < ApplicationController

  def index
    @localities = Locality.includes(:state).order("states.name, localities.name")
  end

  def show
    locality = Locality.find(params[:locality])
    state = locality.state
    election = state.elections.first

    gon.locality_id   = locality.id
    gon.locality_name = locality.name
    gon.locality_info = "#{locality.name}, #{state.name}"
    gon.election_info = "#{election.held_on.strftime('%B %e, %Y')} General Election"
    gon.contests      = locality.contests.map { |c| { id: c.id, office: c.office } }

    gon.mapCenterLat  = -93.147
    gon.mapCenterLon  = 45.005988
    gon.mapZoom       = 11
  end

end

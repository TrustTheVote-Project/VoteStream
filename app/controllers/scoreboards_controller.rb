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

    contests = locality.contests.group_by { |c| c.district_type_normalized }
    gon.contests      = contests.inject({}) { |memo, (type, cs)| memo[type] = cs.map { |c| { id: c.id, office: c.office } }; memo }
    gon.referendums   = locality.referendums.map { |r| { id: r.id, title: r.title, subtitle: r.subtitle, question: r.question } }

    gon.mapCenterLat  = -93.147
    gon.mapCenterLon  = 45.005988
    gon.mapZoom       = 11
  end

end

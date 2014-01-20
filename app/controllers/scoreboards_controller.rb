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

    gon.mapCenterLat  = -93.147
    gon.mapCenterLon  = 45.005988
    gon.mapZoom       = 11

    # TODO: These colors should be set on county basis
    gon.partyColors = {
      republican: [ '#ffcfc5', '#f4a192', '#f47c6d', '#f15149' ],
      democrat:   [ '#c4c4d3', '#9997b4', '#73739a', '#4c5986' ],
      other:      [ '#fdfec5', '#fbfe8f', '#fbfe63', '#fbfe56' ]
    }

    gon.categories = {
      DataController::CATEGORY_REFERENDUMS => I18n.t('scoreboard.header.left_menu.categories.referenda'),
      'Federal' => I18n.t('scoreboard.header.left_menu.categories.federal'),
      'State'   => I18n.t('scoreboard.header.left_menu.categories.state'),
      'MCD'     => I18n.t('scoreboard.header.left_menu.categories.local'),
      'Other'   => I18n.t('scoreboard.header.left_menu.categories.other')
    }

    gon.defaultCategory  = DataProcessor.default_category(locality)
    gon.percentReporting = DataProcessor.percent_reporting(locality)
  end

end

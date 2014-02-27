class ScoreboardsController < ApplicationController

  def index
    @localities = Locality.includes(:state).order("states.name, localities.name")
  end

  def show
    locality          = Locality.find(params[:locality])
    state             = locality.state
    election          = state.elections.first

    gon.locality_id   = locality.id
    gon.locality_name = locality.name.titleize
    gon.locality_info = "#{locality.name.titleize}, #{state.name}"
    gon.election_info = "#{election.held_on.strftime('%Y')} General Election"

    gon.mapCenterLat  = -93.147
    gon.mapCenterLon  = 45.005988
    gon.mapZoom       = 11

    colors     = AppConfig['map_color']['colors']
    threshold  = AppConfig['map_color']['threshold']
    saturation = AppConfig['map_color']['saturation']
    gon.colorScheme = {
      colors: {
        notVoting:    colors['not_voting'],
        notReporting: colors['not_reporting']
      },

      saturation: [
        saturation['high'],
        saturation['middle'],
        saturation['low']
      ],

      threshold: {
        lower: threshold['lower'],
        upper: threshold['upper']
      }
    }

    gon.tweetText = I18n.t('scoreboard.tweet')

    gon.categories = {
      'referenda' => I18n.t('scoreboard.header.left_menu.categories.referenda'),
      'federal'   => I18n.t('scoreboard.header.left_menu.categories.federal'),
      'state'     => I18n.t('scoreboard.header.left_menu.categories.state'),
      'mcd'       => I18n.t('scoreboard.header.left_menu.categories.local'),
      'other'     => I18n.t('scoreboard.header.left_menu.categories.other')
    }

    gon.defaultCategory  = DataProcessor.default_category(locality)
    gon.percentReporting = DataProcessor.percent_reporting(locality)
    gon.reportingIds     = DataProcessor.reporting_precinct_ids(locality)
  end

end

@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.View extends Marionette.Layout
    template: 'scoreboards/show/view'
    id: 'show'

    regions:
      filterBarRegion: '#filter-bar-region'
      resultsSummaryRegion: '#results-summary-region'
      mapRegion: '#map-region'

    onShow: ->
      @si = si = App.request 'entities:scoreboardInfo'
      @layout = new Show.ResultsSummaryLayout

      @filterBarRegion.show new App.ScoreboardsApp.FilterBar.View
        model: App.request('entities:scoreboardInfo')
      @resultsSummaryRegion.show @layout
      @mapRegion.show new Show.MapView
        infoWindow: true
        noPanning: false
        precinctResults: si.get 'precinctResults'
        precinctColors:  si.get 'precinctColors'
        precincts: App.request 'entities:precincts'
        coloringType: si.get('coloringType')

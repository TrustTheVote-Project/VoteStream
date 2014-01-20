@App.module "ScoreboardsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.View extends Marionette.Layout
    template: 'scoreboards/list/view'
    id: 'list'

    regions:
      resultsRegion: '#results-region'
      mapRegion: '#map-region'

    initialize: ->
      si = App.request 'entities:scoreboardInfo'
      @results = si.get 'results'

    onShow: ->
      view = new List.ResultsView
        collection: @results

      mapView = new App.ScoreboardsApp.Show.MapView
        hideControls:     true
        whiteBackground:  true
        noZoom:           true
        noPanning:        true
        infoWindow:       'simple'

      @resultsRegion.show view
      @mapRegion.show mapView

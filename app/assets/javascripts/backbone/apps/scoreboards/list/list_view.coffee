@App.module "ScoreboardsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.View extends Marionette.Layout
    template: 'scoreboards/list/view'
    id: 'list'

    regions:
      resultsRegion: '#results-region'
      summaryRegion: '#summary-region'
      mapRegion: '#map-region'

    initialize: ->
      @si = App.request 'entities:scoreboardInfo'
      @results = @si.get 'results'

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
      @showSummary()

      @si.on 'change:result', @showSummary

    onClose: ->
      @si.off 'change:result', @showSummary

    showSummary: =>
      result = @si.get('result')
      if result?
        rows = result.get('summary').get('rows')
        if result.get('type') == 'c'
          view = new App.ScoreboardsApp.Show.ContestSummaryView
            model:      result
            collection: rows
            simpleVersion: true
        else
          view = new App.ScoreboardsApp.Show.ReferendumSummaryView
            model:      result
            collection: rows
            simpleVersion: true

        @summaryRegion.show view

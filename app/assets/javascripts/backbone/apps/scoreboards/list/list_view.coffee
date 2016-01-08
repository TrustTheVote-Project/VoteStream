@App.module "ScoreboardsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.View extends Marionette.Layout
    template: 'scoreboards/list/view'
    id: 'list'

    regions:
      filterBarRegion:              '#filter-bar-region'
      resultsRegion:                '#results-region'
      mapRegion:                    '#map-region'
      participationSelectorRegion:  '#participation-selector-region'
      percTypeSelectorRegion:       '#percentage-type-selector-region'

    templateHelpers:
      percent: -> App.ScoreboardsApp.Helpers.percent(@votes, @totalVotes)
      percentFormatted: -> App.ScoreboardsApp.Helpers.percentFormatted(@votes, @totalVotes)

    initialize: ->
      @si = App.request 'entities:scoreboardInfo'

    onShow: ->
      view = new List.ResultsLayout
      @resultsRegion.show view

      mapView = new App.ScoreboardsApp.Show.MapView
        hideControls:     true
        whiteBackground:  true
        noZoom:           true
        noPanning:        true
        infoWindow:       'simple'
      @mapRegion.show mapView

      @filterBarRegion.show new App.ScoreboardsApp.FilterBar.View
        model: @si

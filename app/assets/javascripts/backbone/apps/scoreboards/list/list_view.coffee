@App.module "ScoreboardsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.View extends Marionette.Layout
    template: 'scoreboards/list/view'
    id: 'list'

    regions:
      filterBarRegion:              '#filter-bar-region'
      resultsRegion:                '#results-region'
      mapRegion:                    '#map-region'
      participationSelectorRegion:  '#participation-selector-region'

    templateHelpers:
      percent: -> Math.floor(@votes * 100 / (@totalVotes || 1))
      percentFormatted: -> "#{Math.floor(@votes * 1000 / (@totalVotes || 1)) / 10.0}%"

    initialize: ->
      @si = App.request 'entities:scoreboardInfo'
      @results = @si.get 'results'

    onShow: ->
      view = new List.ResultsView
        collection: @results

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

      @participationSelectorRegion.show new ParticipationSelectorView
        model: @si

  class ParticipationSelectorView extends Marionette.ItemView
    template: 'scoreboards/list/_participation_view_selector'

    modelEvents:
      'change:participation': 'render'

    className: 'btn-group'

    events:
      'click button': (e) ->
        e.preventDefault()
        link = $(e.target)
        value = link.data('filter')
        @model.set 'participation', value

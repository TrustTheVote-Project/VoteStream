@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.View extends Marionette.Layout
    template: 'scoreboards/show/view'

    regions:
      contestDetailsRegion: '#contest-details-region'
      precinctsListRegion: '#precincts-list-region'
      mapRegion: '#map-region'

    onShow: ->
      @.contestDetailsRegion.show new ContestDetailsView
        model: App.request 'entities:scoreboardInfo'
      @.mapRegion.show new Show.MapView
        results: App.request 'entities:votingResults'

  class ContestDetailsView extends Marionette.ItemView
    template: 'scoreboards/show/_contest_details'
    tagName: 'table'
    className: 'table'
    modelEvents:
      'change:contest change:region': 'render'


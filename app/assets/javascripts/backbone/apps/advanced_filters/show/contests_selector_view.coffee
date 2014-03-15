@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.ContestsSelectorView extends Marionette.Layout
    template: 'advanced_filters/show/_contests_selector'

    regions:
      federalContestsRegion: '#federal-contests-region'
      stateContestsRegion:   '#state-contests-region'
      localContestsRegion:   '#local-contests-region'
      otherContestsRegion:   '#other-contests-region'

    onShow: ->
      @federalContestsRegion.show new Show.SelectorView title: 'Federal', collection: App.request("entities:refcons:federal")
      @stateContestsRegion.show new Show.SelectorView title: 'State', collection: App.request("entities:refcons:state")
      @localContestsRegion.show new Show.SelectorView title: 'Local', collection: App.request("entities:refcons:local")
      @otherContestsRegion.show new Show.SelectorView title: 'Other', collection: App.request("entities:refcons:other")

@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.ContestsSelectorView extends Marionette.Layout
    template: 'advanced_filters/show/_contests_selector'

    regions:
      federalContestsRegion: '#federal-contests-region'
      stateContestsRegion:   '#state-contests-region'
      localContestsRegion:   '#local-contests-region'
      otherContestsRegion:   '#other-contests-region'

    onShow: ->
      sel = new Backbone.Collection()
      @federalContestsRegion.show new Show.SelectorView title: 'Federal', collection: App.request("entities:refcons:federal"), selection: sel
      @stateContestsRegion.show new Show.SelectorView title: 'State', collection: App.request("entities:refcons:state"), selection: sel
      @localContestsRegion.show new Show.SelectorView title: 'Local', collection: App.request("entities:refcons:local"), selection: sel
      @otherContestsRegion.show new Show.SelectorView title: 'Other', collection: App.request("entities:refcons:other"), selection: sel

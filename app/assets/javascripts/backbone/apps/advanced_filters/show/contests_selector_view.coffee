@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.ContestsSelectorView extends Marionette.Layout
    template: 'advanced_filters/show/_contests_selector'

    regions:
      federalContestsRegion: '#federal-contests-region'
      stateContestsRegion:   '#state-contests-region'
      localContestsRegion:   '#local-contests-region'
      otherContestsRegion:   '#other-contests-region'

    onShow: ->
      af = App.request 'entities:advancedFilter'
      sc = af.get 'selectedContests'
      @federalContestsRegion.show new Show.SelectorView title: 'Federal', collection: App.request("entities:refcons:federal"), selection: sc
      @stateContestsRegion.show new Show.SelectorView title: 'State', collection: App.request("entities:refcons:state"), selection: sc
      @localContestsRegion.show new Show.SelectorView title: 'Local', collection: App.request("entities:refcons:local"), selection: sc
      @otherContestsRegion.show new Show.SelectorView title: 'Other', collection: App.request("entities:refcons:other"), selection: sc

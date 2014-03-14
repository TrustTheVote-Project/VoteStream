@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.ContestsSelectorView extends Marionette.Layout
    template: 'advanced_filters/show/_contests_selector'

    regions:
      federalContestsRegion: '#federal-contests-region'
      stateContestsRegion:   '#state-contests-region'
      localContestsRegion:   '#local-contests-region'
      otherContestsRegion:   '#other-contests-region'

    onShow: ->
      @federalContestsRegion.show new Show.SelectorView title: 'Federal'
      @stateContestsRegion.show new Show.SelectorView title: 'State'
      @localContestsRegion.show new Show.SelectorView title: 'Local'
      @otherContestsRegion.show new Show.SelectorView title: 'Other'

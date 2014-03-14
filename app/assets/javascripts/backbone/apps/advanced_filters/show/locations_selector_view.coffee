@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.LocationsSelectorView extends Marionette.Layout
    template: 'advanced_filters/show/_locations_selector'

    regions:
      federalDistrictsRegion: '#federal-districts-region'
      stateDistrictsRegion:   '#state-districts-region'
      cityDistrictsRegion:    '#city-districts-region'
      otherDistrictsRegion:   '#other-districts-region'
      precinctsRegion:        '#precincts-region'

    onShow: ->
      @federalDistrictsRegion.show new Show.SelectorView title: 'Federal'
      @stateDistrictsRegion.show new Show.SelectorView title: 'State'
      @cityDistrictsRegion.show new Show.SelectorView title: 'City/Town'
      @otherDistrictsRegion.show new Show.SelectorView title: 'Other'
      @precinctsRegion.show new Show.SelectorView title: 'Precincts', rows: 30

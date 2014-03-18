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
      @federalDistrictsRegion.show new Show.SelectorView title: 'Federal', collection: App.request 'entities:districts:federal'
      @stateDistrictsRegion.show new Show.SelectorView title: 'State', collection: App.request 'entities:districts:state'
      @cityDistrictsRegion.show new Show.SelectorView title: 'City/Town', collection: App.request 'entities:districts:local'
      @otherDistrictsRegion.show new Show.SelectorView title: 'Other', collection: App.request 'entities:districts:other'
      @precinctsRegion.show new Show.SelectorView title: 'Precincts', rows: 30, collection: App.request 'entities:precincts'

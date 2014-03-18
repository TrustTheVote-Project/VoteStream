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
      districts = new Backbone.Collection()
      precincts = new Backbone.Collection()
      @federalDistrictsRegion.show new Show.SelectorView title: 'Federal', collection: App.request('entities:districts:federal'), selection: districts
      @stateDistrictsRegion.show new Show.SelectorView title: 'State', collection: App.request('entities:districts:state'), selection: districts
      @cityDistrictsRegion.show new Show.SelectorView title: 'City/Town', collection: App.request('entities:districts:local'), selection: districts
      @otherDistrictsRegion.show new Show.SelectorView title: 'Other', collection: App.request('entities:districts:other'), selection: districts
      @precinctsRegion.show new Show.SelectorView title: 'Precincts', rows: 20, collection: App.request('entities:precincts'), selection: precincts

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
      af = App.request 'entities:advancedFilter'
      sd = af.get 'selectedDistricts'
      sp = af.get 'selectedPrecincts'
      

      @federalDistrictsRegion.show new Show.SelectorView title: 'Federal', collection: App.request('entities:districts:federal'), selection: sd
      @stateDistrictsRegion.show new Show.SelectorView title: 'State', collection: App.request('entities:districts:state'), selection: sd
      @cityDistrictsRegion.show new Show.SelectorView title: 'City/Town', collection: App.request('entities:districts:local'), selection: sd
      @otherDistrictsRegion.show new Show.SelectorView title: 'Other', collection: App.request('entities:districts:other'), selection: sd

      App.execute 'when:fetched', App.request('entities:precincts'), =>
        if @precinctsRegion
          @precinctsRegion.show new Show.SelectorView title: 'Precincts', rows: 20, collection: App.request('entities:precincts'), selection: sp
        

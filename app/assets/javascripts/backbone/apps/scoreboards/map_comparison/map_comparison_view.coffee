@App.module "ScoreboardsApp.MapComparison", (MapComparison, App, Backbone, Marionette, $, _) ->

  class MapComparison.View extends Marionette.Layout
    template: 'scoreboards/map_comparison/view'
    id: 'map_comparison'

    # regions:
      #filterBarRegion:              '#filter-bar-region'
      #mapListRegion:                '#map-list-region'

    initialize: ->
      @si = App.request 'entities:scoreboardInfo'
      @su = App.request 'entities:scoreboardUrl'
      @selected_maps = @si.get 'mapComparisonIds'
      @saved_maps = App.request "entities:savedMaps"
      
    maps: ->
      maps = []
      for map in @saved_maps.maps()        
        if @selected_maps.includes(map.id + '')
          maps.push(map)
      maps
      
      
    templateHelpers: ->
      maps: =>
        @maps()
        
        
    onShow: ->
      for map in @maps()
        @addRegion("newRegion", "#map-region-#{map.id}")
        @newRegion.show new App.ScoreboardsApp.Show.MapView
          infoWindow: true
          noPanning: false
@App.module "ScoreboardsApp.MapComparison", (MapComparison, App, Backbone, Marionette, $, _) ->

  MapComparison.Controller =
    show: ->
      si = App.request 'entities:scoreboardInfo'
      si.set 'view', 'map-comparison'

      App.execute 'when:fetched', App.request('entities:savedMaps'), ->
        view = new MapComparison.View
        App.mainRegion.show view
      

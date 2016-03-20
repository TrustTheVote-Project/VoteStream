@App.module "ScoreboardsApp.MapList", (MapList, App, Backbone, Marionette, $, _) ->

  MapList.Controller =
    show: ->
      si = App.request 'entities:scoreboardInfo'
      si.set 'view', 'map-list'

      App.execute 'when:fetched', App.request('entities:savedMaps'), ->
        view = new MapList.View
        App.mainRegion.show view
      

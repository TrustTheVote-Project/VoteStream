@App.module "ScoreboardsApp.List", (List, App, Backbone, Marionette, $, _) ->

  List.Controller =
    show: ->
      si = App.request 'entities:scoreboardInfo'
      si.set 'view', 'List'

      view = new List.View
      App.mainRegion.show view

@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller =
    show: ->
      si = App.request 'entities:scoreboardInfo'
      si.set 'view', 'Map'

      view = new Show.View
      App.mainRegion.show view

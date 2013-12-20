@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller =
    show: ->
      console.log 'show.show'

      view = new Show.View
      App.mainRegion.show view

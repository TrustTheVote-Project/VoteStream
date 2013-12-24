@App.module "ScoreboardsApp", (ScoreboardsApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    showScoreboard: ->
      ScoreboardsApp.Header.Controller.show()
      ScoreboardsApp.Show.Controller.show()

  ScoreboardsApp.on "start", ->
    API.showScoreboard()

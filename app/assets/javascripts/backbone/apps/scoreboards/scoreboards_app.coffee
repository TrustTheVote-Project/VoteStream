@App.module "ScoreboardsApp", (ScoreboardsApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  class ScoreboardsApp.Router extends Marionette.AppRouter
    appRoutes:
      ""      : "show"
      "list"  : "list"

  API =
    show: ->
      ScoreboardsApp.Show.Controller.show()

    list: ->
      ScoreboardsApp.List.Controller.show()


  App.addInitializer ->
    new ScoreboardsApp.Router
      controller: API

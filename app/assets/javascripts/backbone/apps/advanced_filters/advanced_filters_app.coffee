@App.module "AdvancedFiltersApp", (AdvancedFiltersApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  class AdvancedFiltersApp.Router extends Marionette.AppRouter
    appRoutes:
      "advanced-filters": "show"

  API =
    show: ->
      AdvancedFiltersApp.Show.Controller.show()

  App.addInitializer ->
    new AdvancedFiltersApp.Router
      controller: API

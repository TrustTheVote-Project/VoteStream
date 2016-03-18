@App.module "MetadataApp", (MetadataApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  class MetadataApp.Router extends Marionette.AppRouter
    appRoutes:
      "metadata": "show"
      

  API =
    show: () ->
      MetadataApp.Show.Controller.show()

  App.addInitializer ->
    new MetadataApp.Router
      controller: API

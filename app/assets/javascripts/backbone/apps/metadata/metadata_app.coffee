@App.module "MetadataApp", (MetadataApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  class MetadataApp.Router extends Marionette.AppRouter
    appRoutes:
      "metadata": "show"
      

  API =
    show: () ->
      MetadataApp.Show.Controller.show()

  App.on 'dataready', ->
    new MetadataApp.Router
      controller: API

@App.module "MetadataApp", (MetadataApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  class MetadataApp.Router extends Marionette.AppRouter
    appRoutes:
      "metadata": "show"
      

  API =
    show: () ->
      App.execute 'when:fetched', App.request('entities:electionMetadata'), =>
        MetadataApp.Show.Controller.show()

  App.on 'dataready', ->
    new MetadataApp.Router
      controller: API

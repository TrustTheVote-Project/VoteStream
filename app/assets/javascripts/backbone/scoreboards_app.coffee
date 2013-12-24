@App = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.addRegions
    headerRegion: "#header-region"
    mainRegion: "#main-region"

  App.addInitializer ->
    App.module("ScoreboardsApp").start()

    # Start loading geometries on launch
    App.request 'entities:precinctsGeometries'

  # App.on "initialize:after", ->
  #   if Backbone.history
  #     Backbone.history.start()

  App

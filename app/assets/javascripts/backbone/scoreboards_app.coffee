@App = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.addRegions
    headerRegion: "#header-region"
    mainRegion: "#main-region"

  App.addInitializer ->
    App.module("ScoreboardsApp").start()

  # App.on "initialize:after", ->
  #   if Backbone.history
  #     Backbone.history.start()

  App

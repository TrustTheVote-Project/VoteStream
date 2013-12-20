@App = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.addRegions
    headerRegion: "#header-region"
    mainRegion: "#main-region"

  App.addInitializer ->
    App.module("HeaderApp").start()
    App.module("ScoreboardApp").start()

  App.on "initialize:after", ->
    if Backbone.history
      Backbone.history.start()

  App

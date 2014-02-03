@App = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.addRegions
    headerRegion: "#header-region"
    mainRegion: "#main-region"

  App.addInitializer ->
    App.module("ScoreboardsApp.Header.Controller").show()
    App.module("ScoreboardsApp").start()

  App.rootRoute = "map/#{gon.defaultCategory}/-/-"

  App.on "initialize:after", ->
    @startHistory()
    @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

  App

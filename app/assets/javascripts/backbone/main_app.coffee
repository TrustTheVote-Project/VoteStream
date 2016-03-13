@App = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.addRegions
    headerRegion: "#header-region"
    mainRegion: "#main-region"

  App.addInitializer ->
    
    csrfToken = $("meta[name='csrf-token']").attr("content")
    $.ajaxSetup
      headers: 
        'X-CSRF-Token': csrfToken
    
    
    App.module("HeaderApp").start()
    App.module("ScoreboardsApp").start()
    App.module("AdvancedFiltersApp").start()

  App.rootRoute = "map"

  App.on "initialize:after", ->
    @startHistory()
    @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

  App

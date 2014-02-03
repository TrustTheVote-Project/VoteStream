@App.module "ScoreboardsApp", (ScoreboardsApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  class ScoreboardsApp.Router extends Marionette.AppRouter
    appRoutes:
      "map(/:category)(/:regionType)(/:regionId)(/:refconId)"   : "show"
      "list(/:category)(/:regionType)(/:regionId)(/:refconId)"  : "list"

  setParams = (category, regionType, regionId, refconId) ->
    if regionType == 'd'
      districts = App.request 'entities:districts'
      App.execute 'when:fetched', districts, ->
        district = districts.get regionId
        App.vent.trigger 'filters:set',
          region:   district
          category: category
          refconId: refconId

    else if regionType == 'p'
      precincts = App.request 'entities:precincts'
      App.execute 'when:fetched', precincts, ->
        precinct = precincts.get regionId
        App.vent.trigger 'filters:set',
          region:   precinct
          category: category
          refconId: refconId

    else if regionType == '-'
      App.vent.trigger 'filters:set',
        region:   null
        category: category
        refconId: refconId


  API =
    show: (category, regionType, regionId, refconId) ->
      setParams(category, regionType, regionId, refconId)

      su = App.request 'entities:scoreboardUrl'
      su.setView 'map'
      ScoreboardsApp.Show.Controller.show()

    list: (category, regionType, regionId, refconId) ->
      setParams(category, regionType, regionId, refconId)

      su = App.request 'entities:scoreboardUrl'
      su.setView 'list'
      ScoreboardsApp.List.Controller.show()


  App.addInitializer ->
    new ScoreboardsApp.Router
      controller: API

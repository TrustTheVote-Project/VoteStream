@App.module "ScoreboardsApp", (ScoreboardsApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  class ScoreboardsApp.Router extends Marionette.AppRouter
    appRoutes:
      "map(/:ctype/:cid)(/:rtype)(/:rid)"  : "show"
      "list(/:ctype/:cid)(/:rtype)(/:rid)" : "list"
    
  
  class ScoreboardsApp.Helpers
    @percent: 
      (count, total) -> 
        if total > 0
          Math.floor(count * 100 / (total || 1))
        else
          0
          
    @percentFormatted: 
      (count, total) -> 
        if total > 0 
          "#{Math.floor(count * 1000 / (total || 1)) / 10.0}%" 
        else 
          "0%"
          
    @numberFormatted:
      (number) ->
        numeral(number).format('0,0')
  
  setParams = (ctype, cid, rtype, rid) ->
    waitingFor = []
    if ctype == 'c' or ctype == 'r'
      waitingFor.push App.request('entities:refcons')
    if rtype == 'd'
      waitingFor.push App.request('entities:districts')
    if rtype == 'p'
      waitingFor.push App.request('entities:precincts')

    App.execute 'when:fetched', waitingFor, ->
      refcon = null
      if ctype == 'a'
        refcon = App.request "entities:refcon:all-#{cid}"
      else if ctype == 'c' or ctype == 'r'
        refcons = App.request 'entities:refcons'
        all = refcons.get('all')
        refcon = all.findWhere
          type: ctype
          id:   cid

      region = null
      if rtype == 'd'
        districts = App.request 'entities:districts'
        region = districts.get rid
      else if rtype == 'p'
        precincts = App.request 'entities:precincts'
        region = precincts.get rid
        
      App.vent.trigger 'filters:set',
        region: region
        refcon: refcon


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

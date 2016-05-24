@App.module "ScoreboardsApp", (ScoreboardsApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  class ScoreboardsApp.Router extends Marionette.AppRouter
    appRoutes:
      "map": "map"
      "map/:ctype-:cid(/:region)(/:params)": "map"
      "advanced-map/:params": "advancedMap"
      "map-list": "mapList"
      "map-comparison/:params": "mapComparison"
      "list": "list"
      "list/:ctype-:cid(/:region)(/:params)": "list"
      "advanced-list/:params": "advancedList"
      #'*notFound': 'notFound'
  
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
  
  
    @filtersFromParams: (ctype, cid, rtype, rid, params) ->
      refcon = null
      if ctype == 'a'
        refcon = App.request "entities:refcon:all-#{cid}"
      else if ctype == 'c' or ctype == 'r'
        refcons = App.request 'entities:refcons'
        all = refcons.get('all')
        refcon = all.find (rc) ->
          return rc.get('id') == parseInt(cid) and rc.get('type') == ctype

      region = null
      if rtype == 'd'
        districts = App.request 'entities:districts'
        region = districts.get rid
      else if rtype == 'p'
        precincts = App.request 'entities:precincts'
        region = precincts.get rid
    
      filters = 
        region: region
        refcon: refcon
        channelEarly: true
        channelElectionday: true
        channelAbsentee: true
        coloringType: 'results'
        
  
    
      if params
        for part in params.split "&"
          values = part.split "="
          if values.length == 2 and values[1] == 'off'
            switch values[0]
              when 'dayof'
                filters.channelElectionday = false
              when 'early'
                filters.channelEarly = false
              when 'absentee'
                filters.channelAbsentee = false
          else if values.length == 2
            filters[values[0]] = values[1]
          
      return filters
  
  setAdvancedParams = (params) ->
    App.execute 'when:fetched', [App.request('entities:refcons'), App.request('entities:districts'), App.request('entities:precincts')], ->
      App.vent.trigger 'filters:set', {advanced: params}
    
    
  
    
  setParams = (ctype, cid, rtype, rid, params) ->
    waitingFor = []
    
    if ctype == 'c' or ctype == 'r'
      waitingFor.push App.request('entities:refcons')
    if rtype == 'd'
      waitingFor.push App.request('entities:districts')
    if rtype == 'p'
      waitingFor.push App.request('entities:precincts')

    App.execute 'when:fetched', waitingFor, ->
      filters = ScoreboardsApp.Helpers.filtersFromParams(ctype, cid, rtype, rid, params)
      App.vent.trigger 'filters:set', filters

  API =
    notFound: (params) ->
      console.log(params)
    
    advancedList: (params) ->
      setAdvancedParams(params)
      su = App.request 'entities:scoreboardUrl'
      su.view = 'advanced-list'
      
      ScoreboardsApp.List.Controller.show()
      
      
    map: (ctype, cid, region, params) ->
      if region and region.match('=')
        params = region
      else if region
        regionParts = region.split('-')
        regionType = regionParts[0]
        regionId = regionParts[1]
        
      setParams(ctype, cid, regionType, regionId, params)

      su = App.request 'entities:scoreboardUrl'
      su.setView 'map'
      ScoreboardsApp.Show.Controller.show()

    advancedMap: (params) ->
      setAdvancedParams(params)
      
      su = App.request 'entities:scoreboardUrl'
      su.view = 'advanced-map'
      
      ScoreboardsApp.Show.Controller.show()
    
    mapList: (params) ->
      su = App.request 'entities:scoreboardUrl'
      su.view = 'map-list'
      
      ScoreboardsApp.MapList.Controller.show()
      
    mapComparison: (params) ->
      su = App.request 'entities:scoreboardUrl'
      si = App.request 'entities:scoreboardInfo'
      su.view = 'map-comparison'
      
      si.set 'mapComparisonIds', params.split('-')
      
      ScoreboardsApp.MapComparison.Controller.show()
      
    list: (ctype, cid, region, params)->
      if region and region.match('=')
        params = region
      else if region
        regionParts = region.split('-')
        regionType = regionParts[0]
        regionId = regionParts[1]
        
      setParams(ctype, cid, regionType, regionId, params)

      su = App.request 'entities:scoreboardUrl'
      su.setView 'list'
      ScoreboardsApp.List.Controller.show()

  App.on 'dataready', ->
    new ScoreboardsApp.Router
      controller: API

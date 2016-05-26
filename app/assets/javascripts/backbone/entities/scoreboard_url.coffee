@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class ScoreboardUrl extends Backbone.Model
    initialize: ->
      @si = App.request 'entities:scoreboardInfo'
      @view = null
      @enabled = false
      
      # Params => filters => entity queries
      # UI changes => [Params w/out trigger, filters => entity queries]
      # ScoreboardUrl should listen to this which should pass through to here
      App.vent.on 'filters:set', (options = {}) =>
        #@updatePath(false)
        console.log('filters set', options)
        @si.reloadResults options
          #refcon: options.refcon
      
      
      App.vent.on 'view_changed', =>
        @updatePath(false)
      
      # @si.on 'change:region change:refcon change:channelEarly change:channelElectionday change:channelAbsentee change:coloringType', =>
      #   @updatePath(false)
      @si.on 'change:advanced', =>
        #@updatePath()
        params = @si.get 'advanced'
        if params
          af = App.request 'entities:advancedFilter'
          af.fromParams(params)
          @updatePath()
            
          
    disable: -> @enabled = false
    enable: -> @enabled = true
    enableAndUpdate: ->
      @enable()
      @updatePath()

    setView: (v) ->
      @view = v
      @updatePath(true)

    setComparisonView: (mapIds) ->
      @view = 'map-comparison'
      @si.set 'mapComparisonIds', mapIds
      @updatePath(true)

    updatePath: (refresh) =>
      return unless @enabled
      path = @path()
      console.log("updateing path", path)
      App.navigate path, refresh

    advancedView: ->
      @view == 'advanced-map' || @view == 'advanced-list'

    comparisonView: ->
      @view == 'map-comparison'

    parseUrl: ->
      
    
    path: ->
      if @advancedView()
        af = App.request 'entities:advancedFilter'
        params = af.requestData()
        return "#{@view}/#{$.param(params)}"
      if @comparisonView()
        mapIds = @si.get('mapComparisonIds')
        return "#{@view}/#{mapIds.join('-')}"
      
      parts = []
      parts.push @view or 'map'

      region = @si.get 'region'
      refcon = @si.get('refcon') || App.ScoreboardsApp.Helpers.getDefaultRefcon()

      ctype = refcon.get('type')        
      cid = refcon.get('id')
      ctype = 'a' if ctype == 'all'
      
      if region? or cid != 'federal'
        parts.push ctype + '-' + cid

      # region
      if region?
        rid = region.get('id')
        if region instanceof App.Entities.Precinct
          rtype = 'p'
        else
          rtype = 'd'

        parts.push rtype + '-' + rid

      fullPath = parts.join '/'
      queryParams = []
      if (!@si.get('channelEarly'))
        queryParams.push('early=off') 
      if !@si.get('channelElectionday')
        queryParams.push('dayof=off') 
      if !@si.get('channelAbsentee')
        queryParams.push('absentee=off')
      if @si.get('coloringType') != 'results' 
        queryParams.push('coloringType=' + @si.get('coloringType'))
      if queryParams.length > 0
        fullPath = fullPath + "/" + queryParams.join("&")
      
      return fullPath

  API =
    getScoreboardUrl: ->
      unless Entities.scoreboardUrl?
        Entities.scoreboardUrl = window.su = su = new ScoreboardUrl

      Entities.scoreboardUrl

  App.reqres.setHandler 'entities:scoreboardUrl', -> API.getScoreboardUrl()

  App.on 'dataready', ->
    su = App.request 'entities:scoreboardUrl'
    su.enable()

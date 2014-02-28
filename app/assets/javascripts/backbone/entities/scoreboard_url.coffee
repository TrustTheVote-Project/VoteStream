@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class ScoreboardUrl extends Backbone.Model
    initialize: ->
      @si = App.request 'entities:scoreboardInfo'
      @view = null
      @enabled = false
      @si.on 'change:region change:refcon', @updatePath

    disable: -> @enabled = false
    enable: -> @enabled = true
    enableAndUpdate: ->
      @enable()
      @updatePath()

    setView: (v) ->
      @view = v
      @updatePath()

    updatePath: =>
      return unless @enabled
      App.navigate @path()

    path: ->
      parts = []
      parts.push @view or 'map'

      region = @si.get 'region'
      refcon = @si.get 'refcon'

      # refcon
      ctype = refcon.get('type')
      ctype = 'a' if ctype == 'all'
      cid = refcon.get('id')
      if region? or cid != 'federal'
        parts.push ctype
        parts.push cid

      # region
      if region?
        rid = region.get('id')
        if region instanceof App.Entities.Precinct
          rtype = 'p'
        else
          rtype = 'd'

        parts.push rtype
        parts.push rid

      parts.join '/'


  API =
    getScoreboardUrl: ->
      unless Entities.scoreboardUrl?
        Entities.scoreboardUrl = su = new ScoreboardUrl

      Entities.scoreboardUrl

  App.reqres.setHandler 'entities:scoreboardUrl', -> API.getScoreboardUrl()

  App.on 'initialize:after', ->
    su = App.request 'entities:scoreboardUrl'
    su.enable()

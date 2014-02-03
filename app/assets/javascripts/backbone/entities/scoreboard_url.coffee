@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class ScoreboardUrl extends Backbone.Model
    initialize: ->
      @si = App.request 'entities:scoreboardInfo'
      @view = null

      @si.on 'change:region change:category change:result', @updatePath

    setView: (v) ->
      @view = v
      @updatePath()

    updatePath: =>
      App.navigate @path()

    path: ->
      parts = []
      parts.push @view or 'map'
      parts.push @si.get('category')

      region = @si.get('region')
      if region?
        rid = region.get 'id'
        if region instanceof App.Entities.Precinct
          parts.push 'p'
        else
          parts.push 'd'
        parts.push rid
      else
        parts.push '-'
        parts.push '-'

      result = @si.get('result')
      parts.push result.get('id') if result?
      parts.join '/'


  API =
    getScoreboardUrl: ->
      unless Entities.scoreboardUrl?
        Entities.scoreboardUrl = su = new ScoreboardUrl

      Entities.scoreboardUrl

  App.reqres.setHandler 'entities:scoreboardUrl', -> API.getScoreboardUrl()

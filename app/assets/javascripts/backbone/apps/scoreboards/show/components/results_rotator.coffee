@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  class Show.ResultsRotator
    constructor: ->
      @si = App.request 'entities:scoreboardInfo'
      @results = @si.get 'results'

      @initIndex()
      @si.on 'reset:results change:result', @initIndex, @

    onClose: ->
      @si.off 'reset:results change:result', @initIndex, @

    initIndex: ->
      result  = @si.get 'result'
      @idx    = @results.indexOf result

    next: ->
      @idx++
      @idx = 0 if @results.length <= @idx
      App.vent.trigger 'result:selected', @results.at(@idx)

    prev: ->
      if @idx > 0
        @idx--
      else if @idx is 0
        @idx = (@results.length - 1)
      else
        @idx = 0

      App.vent.trigger 'result:selected', @results.at(@idx)

    hasPrev: -> @idx > 0
    hasNext: -> @idx < @results.length - 1
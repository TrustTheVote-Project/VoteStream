@App.module "ScoreboardsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class CandidateRow extends Marionette.ItemView
    template: 'scoreboards/list/_candidate_row'
    tagName: 'tr'
    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      data.totalVotes = @options.totalVotes
      data
    templateHelpers:
      percent: -> Math.floor(@votes * 100 / (@totalVotes || 1))
      percentFormatted: -> "#{Math.floor(@votes * 1000 / (@totalVotes || 1)) / 10.0}%"
    onShow: ->
      c = @model.get('c')
      $("td", @$el).css(color: c)

  class ContestResultView extends Marionette.CompositeView
    template: 'scoreboards/list/_contest_result'
    className: -> "contest result #{ if @options.selected then 'selected' else '' }".trim()

    itemView: CandidateRow
    itemViewContainer: 'table'
    itemViewOptions: (model, i) ->
      return {
        model: model,
        totalVotes: @model.get('summary').get('votes')
      }

    events:
      'click': (e) ->
        $(".result").removeClass 'selected'
        @$el.addClass 'selected'
        App.vent.trigger 'result:selected', @model


  class ResponseRow extends Marionette.ItemView
    template: 'scoreboards/list/_response_row'
    tagName: 'tr'
    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      data.totalVotes = @options.totalVotes
      data
    templateHelpers:
      percent: -> Math.floor(@votes * 100 / (@totalVotes || 1))
      percentFormatted: -> "#{Math.floor(@votes * 1000 / (@totalVotes || 1)) / 10.0}%"
    onShow: ->
      c = @model.get('c')
      $("td", @$el).css(color: c)

  class ReferendumResultView extends Marionette.CompositeView
    template: 'scoreboards/list/_referendum_result'
    className: -> "referendum result #{ if @options.selected then 'selected' else '' }".trim()

    itemView: ResponseRow
    itemViewContainer: 'table'
    itemViewOptions: (model, i) ->
      return {
        model: model,
        totalVotes: @model.get('summary').get('votes')
      }

    events:
      'click': (e) ->
        $(".result").removeClass 'selected'
        @$el.addClass 'selected'
        App.vent.trigger 'result:selected', @model

  class List.ResultsView extends Marionette.CollectionView
    itemView: ContestResultView

    collectionEvents:
      sync: 'render'

    onBeforeRender: ->
      si = App.request 'entities:scoreboardInfo'
      @selectedModel = si.get('result')

    itemViewOptions: (model, i) ->
      return {
        model: model,
        selected: model == @selectedModel
        collection: model.get('summary').get('rows') }

    getItemView: (model) ->
      if model.get('type') == 'c'
        ContestResultView
      else
        ReferendumResultView

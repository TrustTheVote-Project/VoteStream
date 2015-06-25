@App.module "ScoreboardsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class CandidateRow extends Marionette.ItemView
    template: 'scoreboards/list/_candidate_row'
    tagName: 'div'
    className: ->
      classes = ["row-fluid","candidate"]
      classes.push('extra') if @options.extra
      classes.push('hide') if @options.hidden
      classes.push('winner') if @options.winner
      return classes.join(' ')
    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      data.totalVotes = @options.totalVotes
      data
    templateHelpers:
      percent: -> Math.floor(@votes * 100 / (@totalVotes || 1))
      percentFormatted: -> "#{Math.floor(@votes * 1000 / (@totalVotes || 1)) / 10.0}%"
    onShow: ->
      c = @model.get('c')
      if @model.get('party')['abbr'] == 'stats'
        $(".bar", @$el).hide()
        $(".party", @$el).text('')
        $(".percent", @$el).text($(".votes", @$el).text())
        $(".votes", @$el).hide()

      $("h5, .percent", @$el).css(color: c)
      $(".filler", @$el).css(background: c)

  class ContestResultView extends Marionette.CompositeView
    template: 'scoreboards/list/_contest_result'
    className: -> "contest result #{ if @options.selected then 'selected' else '' }".trim()

    itemView: CandidateRow
    itemViewContainer: 'div.candidates'
    itemViewOptions: (model, i) ->
      return {
        model: model,
        extra: i > 1,
        hidden: !@showParticipation && i > 1,
        winner: i is 0 and gon.percentReporting is 'Final Results',
        totalVotes: @model.get('summary').get('votes')
      }

    initialize: (opts) ->
      @showParticipation = opts.showParticipation

    ui:
      rowsList: 'div.candidates'
      partInfo: 'div.participaction-info'
      showMoreBtn: '#js-show-more'
      showLessBtn: '#js-show-less'

    events:
      'click #js-show-more': (e) ->
        e.preventDefault()
        $('.candidate.extra', @ui.rowsList).show()
        @ui.showMoreBtn.hide()
        @ui.showLessBtn.show()

      'click #js-show-less': (e) ->
        e.preventDefault()
        $('.candidate.extra', @ui.rowsList).hide()
        @ui.showLessBtn.hide()
        @ui.showMoreBtn.show()

      'click': (e) -> @select()

    onShow: ->
      if @options.showParticipation
        @ui.showLessBtn.show()
        @ui.partInfo.show()
      else
        if @collection.length > 2 and !@options.simpleVersion
          @ui.showMoreBtn.show()

      si = App.request 'entities:scoreboardInfo'
      @markSelected() if si.get('result') == @model

    markSelected: ->
      $(".result").removeClass 'selected'
      @$el.addClass 'selected'

    select: ->
      @markSelected()
      App.vent.trigger 'result:selected', @model



  class ResponseRow extends Marionette.ItemView
    template: 'scoreboards/list/_response_row'
    tagName: 'div'
    className: 'row-fluid response'
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

      if @model.get('party')?['abbr'] == 'stats'
        $(".percent", @$el).text($(".votes", @$el).text())
        $(".votes", @$el).hide()

  class ReferendumResultView extends Marionette.CompositeView
    template: 'scoreboards/list/_referendum_result'
    className: -> "referendum result #{ if @options.selected then 'selected' else '' }".trim()

    itemView: ResponseRow
    itemViewContainer: 'div.content'
    itemViewOptions: (model, i) ->
      return {
        model: model,
        totalVotes: @model.get('summary').get('votes')
      }

    events:
      'click': (e) -> @select()

    onShow: ->
      si = App.request 'entities:scoreboardInfo'
      @markSelected() if si.get('result') == @model

    markSelected: ->
      $(".result").removeClass 'selected'
      @$el.addClass 'selected'

    select: ->
      @markSelected()
      App.vent.trigger 'result:selected', @model


  class List.ResultsView extends Marionette.CompositeView
    template: 'scoreboards/list/_results'
    itemView: ContestResultView
    itemViewContainer: '#results'

    collectionEvents:
      sync: 'render'

    modelEvents:
      'change:showParticipation': 'render'
      'change:precinctsReportingCount': 'render'
      'change:totalRegisteredVoters': 'render'

    initialize: (opts) ->
      @model = App.request 'entities:scoreboardInfo'
      @.listenTo @model.get('precinctResults'), 'sync', => @render()
      @.listenTo @model, 'change:result', => @updateMapPosition()

    onBeforeRender: ->
      @selectedModel = @model.get('result')

    itemViewOptions: (model, i) ->
      return {
        model: model
        selected: false
        showParticipation: @model.get('showParticipation')
        collection: model.get('summary').get('rows') }

    getItemView: (model) ->
      if model.get('type') == 'c'
        ContestResultView
      else
        ReferendumResultView

    onCompositeCollectionRendered: ->
      @updateMapPosition()

    updateMapPosition: ->
      selected = $('.result.selected')
      if selected.length > 0
        top = selected.position().top
        $("#map-region").css(top: top, opacity: 1)
      else
        $("#map-region").css(opacity: 0)

    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      data.totalBallots = @model.get('totalBallotsCast')
      data.totalRegisteredVoters = @model.get('totalRegisteredVoters')
      data.turnOut = Math.round((data.totalBallots / (data.totalRegisteredVoters || 1)) * 100)
      data

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
      percent: -> App.ScoreboardsApp.Helpers.percent(@votes, @totalVotes)
      percentFormatted: -> App.ScoreboardsApp.Helpers.percentFormatted(@votes, @totalVotes)
      voteChannels: -> 
        @vote_channels || {}
    onShow: ->
      c = @model.get('c')
      if @model.get('party')['abbr'] == 'stats'
        $(".party", @$el).text('')

      if @model.get('np') and @options.excludeNP
        $(".bar", @$el).hide()
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
      stats = model.get('party')['abbr'] == 'stats'
      return {
        model:       model
        extra:       if @showParticipation then i > 1 else (!stats and i > 1)
        hidden:      if @showParticipation then false else (stats or i > 1)
        winner:      i is 0 and gon.percentReporting is 'Final Results'
        totalVotes:  @options.totalVotes
        excludeNP:   @options.excludeNP
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
      percent: -> App.ScoreboardsApp.Helpers.percent(@votes, @totalVotes)
      percentFormatted: -> App.ScoreboardsApp.Helpers.percentFormatted(@votes, @totalVotes)
    onShow: ->
      c = @model.get('c')
      $("td", @$el).css(color: c)

      if @model.get('np') and @options.excludeNP
        $(".bar", @$el).hide()
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
        totalVotes: @options.totalVotes,
        excludeNP: @options.excludeNP
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

    modelEvents:
      "change:percentageType": 'render'
      "change:showParticipation": 'render'

    collectionEvents:
      sync: 'render'

    initialize: (opts) ->
      @model = App.request 'entities:scoreboardInfo'
      @.listenTo @model.get('precinctResults'), 'sync', => @render()
      @.listenTo @model, 'change:result', => @updateMapPosition()

    onBeforeRender: ->
      @selectedModel = @model.get('result')

    itemViewOptions: (model, i) ->
      summary = model.get('summary')

      if @model.get('showParticipation')
        totalVotes = if @model.get('percentageType') == 'voters' then summary.get('voters') else summary.get('ballots')
      else
        totalVotes = summary.get('votes')

      return {
        model:              model
        totalVotes:         totalVotes
        excludeNP:          @model.get('percentageType') == 'ballots'
        selected:           false
        showParticipation:  @model.get('showParticipation')
        collection:         model.get('summary').get('rows') }

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


  # Participation stats panel
  class ParticipationStatsView extends Marionette.ItemView
    template: 'scoreboards/list/_participation_stats'
    id: 'participation-info'
    className: 'row-fluid result'
    modelEvents:
      'change:showParticipation': 'render'
      'change:precinctsReportingCount': 'render'
      'change:totalRegisteredVoters': 'render'
      'change:totalBallotsCast': 'render'
      'change:electionDayVotes': 'render'
      'change:electionDayPercent': 'render'
      'change:earlyVotes': 'render'
      'change:earlyPercent': 'render'
      'change:absenteeVotes': 'render'
      'change:absenteePercent': 'render'

    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      totalBallots = @model.get('totalBallotsCast')
      totalRegisteredVoters = @model.get('totalRegisteredVoters')
      data.turnOut = Math.round((totalBallots / (totalRegisteredVoters || 1)) * 100)
      data

    onRender: ->
      if @model.get('showParticipation')
        @$el.removeClass 'hide'
      else
        @$el.addClass 'hide'


  # Results section layout
  class List.ResultsLayout extends Marionette.Layout
    template: 'scoreboards/list/_results_layout'
    id: 'results-layout'

    regions:
      participationStatsRegion:     '#participation-stats-region'
      participationSelectorRegion:  '#participation-selector-region'
      percTypeSelectorRegion:       '#percentage-type-selector-region'
      resultsViewRegion:            '#results-view-region'

    initialize: ->
      @si = App.request 'entities:scoreboardInfo'
      @model = @si
      @results = @si.get 'results'

    onShow: ->
      @resultsViewRegion.show new List.ResultsView
        collection: @results

      @participationSelectorRegion.show new ParticipationSelectorView
        model: @si

      @percTypeSelectorRegion.show new PercentageTypeSelectorView
        model: @si

      @participationStatsRegion.show new ParticipationStatsView
        model: @si


  class ParticipationSelectorView extends Marionette.ItemView
    template: 'scoreboards/list/_participation_view_selector'

    modelEvents:
      'change:showParticipation': 'render'

    className: 'btn-group'

    events:
      'click button': (e) ->
        e.preventDefault()
        link = $(e.target)
        value = link.data('filter')
        @model.set 'showParticipation', value

  class PercentageTypeSelectorView extends Marionette.ItemView
    template: 'scoreboards/list/_percentage_type_view_selector'

    modelEvents:
      'change:showParticipation': 'updateVisiblity'
      'change:percentageType': 'render'

    className: 'btn-group'

    events:
      'click button': (e) ->
        e.preventDefault()
        link = $(e.target)
        value = link.data('type')
        @model.set 'percentageType', value

    updateVisiblity: ->
      if @model.get('showParticipation')
        @$el.show()
      else
        @$el.hide()

    onShow: ->
      @updateVisiblity()

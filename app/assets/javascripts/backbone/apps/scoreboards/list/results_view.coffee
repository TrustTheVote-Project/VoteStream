@App.module "ScoreboardsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class CandidateRow extends Marionette.ItemView
    template: 'scoreboards/list/_candidate_row'
    tagName: 'div'
    className: ->
      classes = ["row-fluid","candidate"]
      classes.push('hide') if @.options.hidden
      classes.push('winner') if @.options.winner
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
        hidden: i > 1,
        winner: i is 0 and gon.percentReporting is 'Final Results',
        totalVotes: @model.get('summary').get('votes')
      }

    ui:
      rowsList: 'div.candidates'
      showMoreBtn: '#js-show-more'
      showLessBtn: '#js-show-less'

    events:
      'click #js-show-more': (e) ->
        e.preventDefault()
        $('.candidate.hide', @ui.rowsList).show()
        @ui.showMoreBtn.hide()
        @ui.showLessBtn.show()

      'click #js-show-less': (e) ->
        e.preventDefault()
        $('.candidate.hide', @ui.rowsList).hide()
        @ui.showLessBtn.hide()
        @ui.showMoreBtn.show()

      'click': ->
        $(".result").removeClass 'selected'
        @$el.addClass 'selected'
        App.vent.trigger 'result:selected', @model

      'mouseover': -> do @showMap
      'mouseout': -> do @hideMap

    onShow: ->
      if @collection.length > 2 and !@options.simpleVersion
        @ui.showMoreBtn.show()

    showMap: ->
      #offset = @.$el.offset().top - $('#content').offset().top
      #$('#sidebar').css('margin-top', offset).addClass('active')
      $('#map-region').appendTo(@.$el)
      $('#map-view').trigger('map:show')

    hideMap: ->
      #$('#sidebar').removeClass('active')

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
      'click': (e) ->
        $(".result").removeClass 'selected'
        @$el.addClass 'selected'
        App.vent.trigger 'result:selected', @model

  class List.ResultsView extends Marionette.CompositeView
    template: 'scoreboards/list/_results'
    itemView: ContestResultView
    itemViewContainer: '#results'

    collectionEvents:
      sync: 'render'

    initialize: (opts) ->
      @model = App.request 'entities:scoreboardInfo'

    onBeforeRender: ->
      si = App.request 'entities:scoreboardInfo'
      @selectedModel = si.get('result')

    itemViewOptions: (model, i) ->
      return {
        model: model,
        selected: false #model == @selectedModel
        collection: model.get('summary').get('rows') }

    getItemView: (model) ->
      if model.get('type') == 'c'
        ContestResultView
      else
        ReferendumResultView

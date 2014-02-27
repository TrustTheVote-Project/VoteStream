@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.View extends Marionette.Layout
    template: 'scoreboards/show/view'
    id: 'show'

    regions:
      filterBarRegion: '#filter-bar-region'
      resultsSummaryRegion: '#results-summary-region'
      mapRegion: '#map-region'

    onShow: ->
      @layout = new ResultsSummaryLayout

      @filterBarRegion.show new App.ScoreboardsApp.FilterBar.View
        model: App.request('entities:scoreboardInfo')
      @resultsSummaryRegion.show @layout
      @mapRegion.show new Show.MapView
        infoWindow: true


  class ResultsRotator
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
      @idx--
      @idx = @results.length - 1 if @idx < 0
      @idx = 0 if @idx < 0
      App.vent.trigger 'result:selected', @results.at(@idx)

    hasPrev: -> @idx > 0
    hasNext: -> @idx < @results.length - 1


  class ResultsSummaryLayout extends Marionette.Layout
    template: 'scoreboards/show/_results_summary_layout'
    tagName:   'table'
    className: ''

    regions:
      summaryRegion: '#summary-region'

    initialize: ->
      @rotator = new ResultsRotator

      @si = App.request 'entities:scoreboardInfo'
      @si.on 'change:result', @updateLayout, @

    ui: ->
      prevRefCon: '#js-prev-refcon a'
      nextRefCon: '#js-next-refcon a'

    onShow: -> @updateLayout()
    onClose: ->
      @rotator.onClose()
      @si.off 'change:result', @updateLayout, @

    events:
      'click #js-prev-refcon a': (e) ->
        e.preventDefault()
        return if $(e.target).attr('disabled')
        @rotator.prev()

      'click #js-next-refcon a': (e) ->
        e.preventDefault()
        return if $(e.target).attr('disabled')
        @rotator.next()

    updateLayout: ->
      result = @si.get('result')
      if result?
        rows = result.get('summary').get('rows')
        if result.get('type') == 'c'
          view = new Show.ContestSummaryView
            model:      result
            collection: rows
        else
          view = new Show.ReferendumSummaryView
            model:      result
            collection: rows

        @summaryRegion.show view

      else
        @summaryRegion.show new NoRefConView

      if @rotator.hasPrev() then @ui.prevRefCon.removeAttr('disabled') else @ui.prevRefCon.attr('disabled', true)
      if @rotator.hasNext() then @ui.nextRefCon.removeAttr('disabled') else @ui.nextRefCon.attr('disabled', true)

  class NoRefConView extends Marionette.ItemView
    template: 'scoreboards/show/_no_refcon'


  class ContestSummaryRowView extends Marionette.ItemView
    template: 'scoreboards/show/_contest_summary_row'
    tagName:  'li'
    className: ->
      if @.options.hidden then 'hide' else ''
    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      data.totalVotes = @options.totalVotes
      data
    templateHelpers:
      percent: -> Math.floor(@votes * 100 / (@totalVotes || 1))
      percentFormatted: -> "#{Math.floor(@votes * 1000 / (@totalVotes || 1)) / 10.0}%"
    onShow: ->
      c = @model.get('c')
      $("h5", @$el).css(color: c)
      $(".filler", @$el).css(background: c)


  class ReferendumSummaryRowView extends Marionette.ItemView
    template: 'scoreboards/show/_referendum_summary_row'
    tagName:  'li'
    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      data.totalVotes = @options.totalVotes
      data
    templateHelpers:
      percent: -> Math.floor(@votes * 100 / (@totalVotes || 1))
      percentFormatted: -> "#{Math.floor(@votes * 1000 / (@totalVotes || 1)) / 10.0}%"
    onShow: ->
      c = @model.get('c')
      $("h5", @$el).css(color: c)
      $(".filler", @$el).css(background: c)


  # referendum details region
  class Show.ReferendumSummaryView extends Marionette.CompositeView
    template: 'scoreboards/show/_referendum_summary'
    itemView: ReferendumSummaryRowView

    itemViewContainer: 'ul'
    itemViewOptions: (m, i) ->
      return {
        totalVotes: @model.get('summary').get('votes')
      }

    ui:
      title: 'h4'

    onShow: ->
      if !@options.simpleVersion
        @ui.title.show()

  class Show.ContestSummaryView extends Marionette.CompositeView
    template: 'scoreboards/show/_contest_summary'
    itemView: ContestSummaryRowView

    itemViewContainer: 'ul'
    itemViewOptions: (m, i) ->
      return {
        hidden:     i > 1,
        totalVotes: @model.get('summary').get('votes')
      }

    ui:
      title: 'h4'
      rowsList: 'ul'
      showMoreBtn: '#js-show-more'
      showLessBtn: '#js-show-less'

    onShow: ->
      if @collection.length > 2 and !@options.simpleVersion
        @ui.showMoreBtn.show()

      if !@options.simpleVersion
        @ui.title.show()

    events:
      'click #js-show-more': (e) ->
        e.preventDefault()
        $('li.hide', @ui.rowsList).show()
        @ui.showMoreBtn.hide()
        @ui.showLessBtn.show()

      'click #js-show-less': (e) ->
        e.preventDefault()
        $('li.hide', @ui.rowsList).hide()
        @ui.showLessBtn.hide()
        @ui.showMoreBtn.show()

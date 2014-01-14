@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.View extends Marionette.Layout
    template: 'scoreboards/show/view'

    regions:
      resultsSummaryRegion: '#results-summary-region'
      mapRegion: '#map-region'

    onShow: ->
      @layout = new ResultsSummaryLayout
      @resultsSummaryRegion.show @layout
      @mapRegion.show new Show.MapView


  class RefConRotator
    constructor: ->
      @si = App.request 'entities:scoreboardInfo'
      @refcons = @si.get 'refcons'

      @initIndex()
      @si.on 'reset:refcons', => @initIndex()
      @si.on 'change:refcon', => @initIndex()

    initIndex: ->
      refcon  = @si.get 'refcon'
      @idx    = @refcons.indexOf refcon

    next: ->
      @idx++
      @idx = 0 if @refcons.length <= @idx
      @si.set 'refcon', @refcons.at(@idx)

    prev: ->
      @idx--
      @idx = @refcons.length - 1 if @idx < 0
      @idx = 0 if @idx < 0
      @si.set 'refcon', @refcons.at(@idx)

    hasPrev: -> @idx > 0
    hasNext: -> @idx < @refcons.length - 1

  class ResultsSummaryLayout extends Marionette.Layout
    template: 'scoreboards/show/_results_summary_layout'
    tagName:   'table'
    className: ''

    regions:
      summaryRegion: '#summary-region'

    initialize: ->
      @rotator = new RefConRotator

      @si = App.request 'entities:scoreboardInfo'
      @si.get('refcons').on 'reset', => @updateLayout()
      @si.get('results').on 'sync', => @updateLayout()

    ui: ->
      prevRefCon: '#js-prev-refcon a'
      nextRefCon: '#js-next-refcon a'

    onShow: ->
      @updateLayout()

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
      results = @si.get('results')
      if results.hasData()
        @summaryRegion.show new SummaryView
          model:      results
          collection: results.get('summary').get('rows')
      else
        @summaryRegion.show new NoRefConView

      if @rotator.hasPrev() then @ui.prevRefCon.removeAttr('disabled') else @ui.prevRefCon.attr('disabled', true)
      if @rotator.hasNext() then @ui.nextRefCon.removeAttr('disabled') else @ui.nextRefCon.attr('disabled', true)

  class NoRefConView extends Marionette.ItemView
    template: 'scoreboards/show/_no_refcon'

  class SummaryRowView extends Marionette.ItemView
    template: 'scoreboards/show/_refcon_summary_row'
    tagName:  'li'
    className: ->
      "#{if @.options.hidden then 'hide' else ''} party-#{(@options.candidate.get('party') || "").toLowerCase().replace(/[^a-z]/g, '')}".trim()
    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      data.totalVotes = @options.totalVotes
      data.name       = @options.candidate.get('name')
      data.party      = @options.candidate.get('party')
      data
    templateHelpers:
      percent: ->
        Math.floor(@votes * 100 / @totalVotes)

      percentFormatted: ->
        "#{Math.floor(@votes * 1000 / @totalVotes) / 10.0}%"

  class SummaryView extends Marionette.CompositeView
    template: 'scoreboards/show/_refcon_summary'
    itemView: SummaryRowView
    itemViewContainer: 'ul'
    itemViewOptions: (m, i) ->
      return {
        hidden:     i > 1,
        candidate:  @model.get('candidates').get(m.get('cid')),
        totalVotes: @model.get('summary').get('total_votes') }

    ui:
      rowsList: 'ul'
      showMoreBtn: '#js-show-more'
      showLessBtn: '#js-show-less'

    onShow: ->
      if @collection.length > 2
        @ui.showMoreBtn.show()

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



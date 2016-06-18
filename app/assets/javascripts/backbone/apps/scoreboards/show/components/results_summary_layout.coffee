@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  class Show.ResultsSummaryLayout extends Marionette.Layout
    template: 'scoreboards/show/_results_summary_layout'
    className: 'span12'

    regions:
      summaryPagination: '#summary-pagination'
      summaryRegion: '#summary-region'

    initialize: ->
      @si = App.request 'entities:scoreboardInfo'
      @si.on 'change:result', @updateLayout, @

    onShow: ->
      @summaryPagination.show new Show.SummaryPagination
      @updateLayout()

    onClose: -> @si.off('change:result', @updateLayout, @)

    updateLayout: ->
      result = @si.get('result')
      if result?
        rows = result.get('summary').get('rows')
        if result.get('type') == 'c'
          view = new Show.ContestSummaryView
            model:      result
            collection: rows
            si: @si
        else
          view = new Show.ReferendumSummaryView
            model:      result
            collection: rows
            si: @si

        @summaryRegion.show view

      else
        @summaryRegion.show new Show.NoRefConView
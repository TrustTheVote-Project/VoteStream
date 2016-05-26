@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  class Show.ReferendumSummaryView extends Marionette.CompositeView
    template: 'scoreboards/show/_referendum_summary'
    itemView: Show.ReferendumSummaryRowView

    itemViewContainer: 'ul'
    itemViewOptions: (m, i) ->
      return {
        winner:     i is 0 and App.percentReporting is 'Final Results',
        totalVotes: @model.get('summary').get('votes')
      }

    ui:
      title: 'h4'

    onShow: ->
      if !@options.simpleVersion
        @ui.title.removeClass('hide')
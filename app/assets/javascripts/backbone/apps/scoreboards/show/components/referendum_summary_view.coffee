@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  class Show.ReferendumSummaryView extends Marionette.CompositeView
    template: 'scoreboards/show/_referendum_summary'
    itemView: Show.ReferendumSummaryRowView

    itemViewContainer: 'ul'
    itemViewOptions: (m, i) ->
      stats = m.get('stats')
      showByRegVoters = @options.si.get('percentageType') == 'voters'
      return {
        winner:     i is 0 and App.percentReporting is 'Final Results',
        totalVotes: @model.get('summary').get('votes')
        voters: @model.get('summary').get('voters')
        extra:      stats
        hidden:     stats and !showByRegVoters
        showByRegVoters: showByRegVoters
      }
      
      

    ui:
      title: 'h4'

    onShow: ->
      if !@options.simpleVersion
        @ui.title.removeClass('hide')
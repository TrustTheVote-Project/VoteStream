@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  class Show.ContestSummaryView extends Marionette.CompositeView
    template: 'scoreboards/show/_contest_summary'
    itemView: Show.ContestSummaryRowView

    itemViewContainer: 'ul'
    itemViewOptions: (m, i) ->
      stats = m.get('party')['abbr'] == 'stats'
      return {
        extra:      !stats and i > 1
        hidden:     stats or i > 1
        winner:     i is 0 and App.percentReporting is 'Final Results'
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
        @ui.title.removeClass('hide')

    events:
      'click #js-show-more': (e) ->
        e.preventDefault()
        $('li.extra', @ui.rowsList).show()
        @ui.showMoreBtn.hide()
        @ui.showLessBtn.show()

      'click #js-show-less': (e) ->
        e.preventDefault()
        $('li.extra', @ui.rowsList).hide()
        @ui.showLessBtn.hide()
        @ui.showMoreBtn.show()
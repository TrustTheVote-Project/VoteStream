@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  class Show.ContestSummaryRowView extends Marionette.ItemView
    template: 'scoreboards/show/_contest_summary_row'
    tagName:  'li'
    className: ->
      classes = []
      classes.push('extra') if @options.extra
      classes.push('hide') if @options.hidden
      classes.push('winner') if @options.winner
      return classes.join(' ')
    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      data.totalVotes = @options.totalVotes
      data
    templateHelpers: ->
      percent: -> App.ScoreboardsApp.Helpers.percent(@votes, @totalVotes)
      percentFormatted: -> App.ScoreboardsApp.Helpers.percentFormatted(@votes, @totalVotes)
      
    onShow: ->
      c = @model.get('c')
      $("h5, .percent", @$el).css(color: c)
      $(".filler", @$el).css(background: c)

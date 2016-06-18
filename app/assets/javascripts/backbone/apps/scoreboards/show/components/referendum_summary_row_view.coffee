@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  class Show.ReferendumSummaryRowView extends Marionette.ItemView
    template: 'scoreboards/show/_referendum_summary_row'
    tagName:  'li'
    className: ->
      classes = []
      classes.push('extra') if @options.extra
      classes.push('hide') if @options.hidden
      classes.push('winner') if @options.winner
      return classes.join(' ')
    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      data.totalVotes = if @options.showByRegVoters then @options.voters else @options.totalVotes
      data
    templateHelpers: ->
      percent: -> App.ScoreboardsApp.Helpers.percent(@votes, @totalVotes)
      percentFormatted: -> App.ScoreboardsApp.Helpers.percentFormatted(@votes, @totalVotes)
      
    onShow: ->
      c = @model.get('c')
      $("h5", @$el).css(color: c)
      $(".filler", @$el).css(background: c)

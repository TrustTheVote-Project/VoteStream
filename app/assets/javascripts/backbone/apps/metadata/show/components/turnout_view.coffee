@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.TurnoutView extends Marionette.ItemView
    template: 'metadata/show/_turnout'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @total = @metaData.get('total_valid_votes')
      @registrants = @metaData.get('registrants')
      @registrantsNotVoted = @registrants - @total
      @overvotes = @metaData.get('overvotes')
      @undervotes = @metaData.get('undervotes')
      @votesNotCounted = (@overvotes + @undervotes)
      
    serializeData: ->
      return {
        turnoutPercentage:  App.ScoreboardsApp.Helpers.percentFormatted(@total, @registrants)
        total: App.ScoreboardsApp.Helpers.numberFormatted(@total)
        registrantsNotVoted: App.ScoreboardsApp.Helpers.numberFormatted(@registrantsNotVoted)
        registrantsNotVotedPercentage:  App.ScoreboardsApp.Helpers.percentFormatted(@registrantsNotVoted, @registrants)
        votesNotCounted: App.ScoreboardsApp.Helpers.numberFormatted(@votesNotCounted)
        votesNotCountedPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@votesNotCounted, @registrants)
      }

    onShow: ->
      @renderPieChart()

      
    renderPieChart: ->
      
      @pieData = [
        {
          value: @total
          color: "#41aef4"
          highlight: "#41aef4"
          label: "In Person"
        },
        {
          value: @registrantsNotVoted
          color: "#5a7688"
          highlight: "#5a7688"
          label: "In Person Early"
        },
        {
          value: @votesNotCounted
          color: "#ebe5e1"
          highlight: "#ebe5e1"
          label: "Absentee"
        }
        
      ]
      @pieOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
        
      ctx = $("#metadata-turnout-chart").get(0).getContext("2d")
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)

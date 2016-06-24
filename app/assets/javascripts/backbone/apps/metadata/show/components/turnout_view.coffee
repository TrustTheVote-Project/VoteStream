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
      @votesNotCounted = @metaData.get('rejected') || 0
      #@votesNotCounted = (@overvotes + @undervotes)
      
    serializeData: ->
      return {
        turnoutPercentage:  App.ScoreboardsApp.Helpers.percentFormatted(@total, @registrants)
        totalRegistrants: App.ScoreboardsApp.Helpers.numberFormatted(@registrants)
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
          color: "#00cc7a"
          highlight: "#00cc7a"
          label: "Voted"
        },
        {
          value: @registrantsNotVoted
          color: "#e68a00"
          highlight: "#e68a00"
          label: "Registered Not Voted"
        },
        {
          value: @votesNotCounted
          color: "#ff8080"
          highlight: "#ff8080"
          label: "Not Counted"
        }
        
      ]
      @pieOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
        
      ctx = $("#metadata-turnout-chart").get(0).getContext("2d")
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)

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
      demographics = @metaData.get('demographics')
      @votesNotCounted = demographics['absentee_rejected'] + demographics['provisional_rejected']
      @regRejected = demographics['registration_rejected']
      #@votesNotCounted = (@overvotes + @undervotes)
      
    serializeData: ->
      return {
        turnoutPercentage:  App.ScoreboardsApp.Helpers.percentFormatted(@total, @registrants)
        totalRegistrants: App.ScoreboardsApp.Helpers.numberFormatted(@registrants)
        total: App.ScoreboardsApp.Helpers.numberFormatted(@total)
        registrantsNotVoted: App.ScoreboardsApp.Helpers.numberFormatted(@registrantsNotVoted)
        registrantsNotVotedPercentage:  App.ScoreboardsApp.Helpers.percentFormatted(@registrantsNotVoted, @registrants)
        votesNotCounted: if @votesNotCounted then App.ScoreboardsApp.Helpers.numberFormatted(@votesNotCounted) else "N/A"
        votesNotCountedPercentage: if @votesNotCounted then App.ScoreboardsApp.Helpers.percentFormatted(@votesNotCounted, @registrants) else "N/A"
        regRejected: if @regRejected then App.ScoreboardsApp.Helpers.numberFormatted(@regRejected) else "N/A"
        regRejectedPercentage: if @regRejected then App.ScoreboardsApp.Helpers.percentFormatted(@regRejected, @registrants) else "N/A"
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
        },
        {
          value: @regRejected,
          color: "#aa3030",
          highlight: "#aa3030",
          label: "Registration Rejected"
        }
        
      ]
      @pieOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
        
      ctx = $("#metadata-turnout-chart").get(0).getContext("2d")
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)

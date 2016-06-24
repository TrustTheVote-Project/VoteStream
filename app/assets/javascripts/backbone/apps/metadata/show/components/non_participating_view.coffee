@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.NonParticipatingView extends Marionette.ItemView
    template: 'metadata/show/_non_participating'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @total = @metaData.get('total_valid_votes')
      @registrants = @metaData.get('registrants')
      @absentee = @metaData.get('absentee')
      @ab_counted = @demographics['absentee_success']
      @ab_rejected = @demographics['absentee_rejected']
      @ab_unreturned = @absentee - (@ab_counted + @ab_rejected)
      
      
      @registrantsNotVoted = @registrants - @total
      
      @provisionalUncounted = @demographics['provisional_rejected'] || 0 
      @totalNonParticipating = @registrantsNotVoted + @ab_rejected + @ab_unreturned + @provisionalUncounted
      
    serializeData: ->
      return {
        totalNonParticipating: App.ScoreboardsApp.Helpers.numberFormatted(@totalNonParticipating)
        registrantsNotVoted: App.ScoreboardsApp.Helpers.numberFormatted(@registrantsNotVoted)
        registrantsNotVotedPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@registrantsNotVoted, @totalNonParticipating)
        absenteeRejected: App.ScoreboardsApp.Helpers.numberFormatted(@ab_rejected)
        absenteeRejectedPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@ab_rejected, @totalNonParticipating)
        absenteeUnreturned: App.ScoreboardsApp.Helpers.numberFormatted(@ab_unreturned)
        absenteeUnreturnedPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@ab_unreturned, @totalNonParticipating)
        provisionalUncounted: App.ScoreboardsApp.Helpers.numberFormatted(@provisionalUncounted)
        provisionalUncountedPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@provisionalUncounted, @totalNonParticipating)
      }
      
    onShow: ->
      @renderPieChart()

    
    renderPieChart: ->
    
      @pieData = [
        {
          value: @registrantsNotVoted
          color: "#e68a00"
          highlight: "#e68a00"
          label: "Registered Not Voted"
        },        
        {
          value: @ab_unreturned
          color: "#aba5a1"
          label: "Absentee Unreturned"
        },
        {
          value: @ab_rejected
          color: "#ff8080"
          label: "Absentee Rejected"
        },
        {
          value: @provisionalUncounted
          color: "#cbc5c1"
          label: "Provisional"
        }
      
      ]
      @pieOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
      
      ctx = $("#metadata-non-participating-chart").get(0).getContext("2d")
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)
    
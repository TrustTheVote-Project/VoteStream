@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.NonParticipatingView extends Marionette.ItemView
    template: 'metadata/show/_non_participating'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @total = @metaData.get('total_valid_votes')
      @registrants = @metaData.get('registrants')
      @absentee = @metaData.get('absentee')
      @absenteeUncounted = .2 * @absentee   #FAKE
      
      @registrantsNotVoted = @registrants - @total
      @domestic = .88 * @registrantsNotVoted
      @military = .07 * @registrantsNotVoted
      @overseas = .05 * @registrantsNotVoted
      
      @provisionalUncounted = 111
      @totalNonParticipating = @registrantsNotVoted + @absenteeUncounted + @provisionalUncounted
      
    serializeData: ->
      return {
        totalNonParticipating: App.ScoreboardsApp.Helpers.numberFormatted(@totalNonParticipating)
        domestic: App.ScoreboardsApp.Helpers.numberFormatted(@domestic)
        domesticPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@domestic, @totalNonParticipating)
        overseas: App.ScoreboardsApp.Helpers.numberFormatted(@overseas)
        overseasPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@overseas, @totalNonParticipating)
        military: App.ScoreboardsApp.Helpers.numberFormatted(@military)
        militaryPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@military, @totalNonParticipating)
        absenteeUncounted: App.ScoreboardsApp.Helpers.numberFormatted(@absenteeUncounted)
        absenteeUncountedPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@absenteeUncounted, @totalNonParticipating)
        provisionalUncounted: App.ScoreboardsApp.Helpers.numberFormatted(@provisionalUncounted)
        provisionalUncountedPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@provisionalUncounted, @totalNonParticipating)
      }
      
    onShow: ->
      @renderPieChart()

    
    renderPieChart: ->
    
      @pieData = [
        {
          value: @domestic
          color: "#113d54"
          label: "In Person"
        },
        {
          value: @overseas
          color: "#5a7688"
          label: "In Person Early"
        },
        {
          value: @military
          color: "#f29101"
          label: "Absentee"
        },
        {
          value: @absenteeUncounted
          color: "#aba5a1"
          label: "Absentee"
        },
        {
          value: @provisionalUncounted
          color: "#cbc5c1"
          label: "Absentee"
        }
      
      ]
      @pieOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
      
      ctx = $("#metadata-non-participating-chart").get(0).getContext("2d")
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)
    
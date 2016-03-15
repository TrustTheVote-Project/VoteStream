@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.TotalCountedView extends Marionette.ItemView
    template: 'metadata/show/_total_counted'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @total = @metaData.get('total_valid_votes')
      @electionDay = @metaData.get('election_day') || 0
      @early = @metaData.get('early') || 0
      @absentee = @metaData.get('absentee') || 0
      
      
    serializeData: ->
      data = {}
      data.total = App.ScoreboardsApp.Helpers.numberFormatted(@total)
      data.electionDay = App.ScoreboardsApp.Helpers.numberFormatted(@electionDay)
      data.electionDayPercentage = App.ScoreboardsApp.Helpers.percentFormatted(@electionDay, @total)
      data.early = App.ScoreboardsApp.Helpers.numberFormatted(@early)
      data.earlyPercentage = App.ScoreboardsApp.Helpers.percentFormatted(@early, @total)
      data.absentee = App.ScoreboardsApp.Helpers.numberFormatted(@absentee)
      data.absenteePercentage = App.ScoreboardsApp.Helpers.percentFormatted(@absentee, @total)
      
      data

    onShow: ->
      @renderPieChart()

      
    renderPieChart: ->
      
      @pieData = [
        {
          value: @electionDay
          color: "#41aef4"
          highlight: "#41aef4"
          label: "In Person"
        },
        {
          value: @early
          color: "#5a7688"
          highlight: "#5a7688"
          label: "In Person Early"
        },
        {
          value: @absentee
          color: "#ebe5e1"
          highlight: "#ebe5e1"
          label: "Absentee"
        }
        
      ]
      @pieOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
        
      ctx = $("#metadata-total-counted-chart").get(0).getContext("2d")
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)

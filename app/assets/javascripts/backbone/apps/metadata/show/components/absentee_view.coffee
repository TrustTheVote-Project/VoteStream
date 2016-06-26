@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.AbsenteeView extends Marionette.ItemView
    template: 'metadata/show/_absentee'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @voters = @metaData.get('total_valid_votes')
      @absentee = @metaData.get('absentee')
      @counted = @demographics['absentee_success']
      @rejected = @demographics['absentee_rejected']
      @unreturned = @absentee - (@counted + @rejected)
      
      
      
    serializeData: ->
      return {
        voters:  App.ScoreboardsApp.Helpers.numberFormatted(@voters)
        absentee:  App.ScoreboardsApp.Helpers.numberFormatted(@absentee)
        absentee_percent: App.ScoreboardsApp.Helpers.percentFormatted(@absentee, @voters)
        counted: App.ScoreboardsApp.Helpers.numberFormatted(@counted)
        counted_percent: App.ScoreboardsApp.Helpers.percentFormatted(@counted, @absentee)
        rejected: App.ScoreboardsApp.Helpers.numberFormatted(@rejected)
        rejected_percent: App.ScoreboardsApp.Helpers.percentFormatted(@rejected, @absentee)
        unreturned: App.ScoreboardsApp.Helpers.numberFormatted(@unreturned)
        unreturned_percent: App.ScoreboardsApp.Helpers.percentFormatted(@unreturned, @absentee)        
      }
      
    onShow: ->
      @renderPieChart()
    
    renderPieChart: ->
    
      @pieData = [
        {
          value: @counted
          color: "#00cc7a"
          highlight: "#00cc7a"
          label: "Counted Absentee"
        },
        {
          value: @unreturned
          color: "#e68a00"
          highlight: "#e68a00"
          label: "Unreturned absentee"
        },
        {
          value: @rejected
          color: "#ff8080"
          highlight: "#ff8080"
          label: "Rejected Absentee"
        }
      
      ]
      @pieOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
      
      ctx = $("#metadata-absentee-chart").get(0).getContext("2d")
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)
      
      
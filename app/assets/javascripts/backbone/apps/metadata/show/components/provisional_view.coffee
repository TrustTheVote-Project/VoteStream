@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.ProvisionalView extends Marionette.ItemView
    template: 'metadata/show/_provisional'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @voters = @metaData.get('total_valid_votes')
      @counted = @demographics['provisional_success'] || 0
      @rejected = @demographics['provisional_rejected'] || 0 
      @provisional = @counted + @rejected
      
    serializeData: ->
      return {
        voters:  App.ScoreboardsApp.Helpers.numberFormatted(@voters)
        provisional:  App.ScoreboardsApp.Helpers.numberFormatted(@provisional)
        provisional_percent: App.ScoreboardsApp.Helpers.percentFormatted(@provisional, @voters)
        counted: App.ScoreboardsApp.Helpers.numberFormatted(@counted)
        counted_percent: App.ScoreboardsApp.Helpers.percentFormatted(@counted, @provisional)
        rejected: App.ScoreboardsApp.Helpers.numberFormatted(@rejected)
        rejected_percent: App.ScoreboardsApp.Helpers.percentFormatted(@rejected, @provisional)
      }
      
    onShow: ->
      @renderPieChart()
    
    renderPieChart: ->
    
      @pieData = [
        {
          value: @counted
          color: "#00cc7a"
          highlight: "#00cc7a"
          label: "Counted Provisional"
        },
        {
          value: @unreturned
          color: "#e68a00"
          highlight: "#e68a00"
          label: "Rejected Provisional"
        }
      ]
      @pieOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
      
      ctx = $("#metadata-provisional-chart").get(0).getContext("2d")
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)
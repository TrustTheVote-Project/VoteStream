
@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.UocavaView extends Marionette.ItemView
    template: 'metadata/show/_uocava'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @voters = @metaData.get('total_valid_votes')
      @absentee = @metaData.get('absentee')
      @counted = @demographics['absentee_success']
      @rejected = @demographics['absentee_rejected']
      
      @military_counted = @demographics["military_success"] || 0
      @military_rejected = @demographics["military_rejected"] || 0
      @military_dep_counted = @demographics["military_dep_success"] || 0
      @military_dep_rejected = @demographics["military_dep_rejected"] || 0
      @intent_to_return_counted = @demographics["intent_to_return_success"] || 0
      @intent_to_return_rejected = @demographics["intent_to_return_rejected"] || 0
      @uncertain_return_counted = @demographics["uncertain_return_success"] || 0
      @uncertain_return_rejected = @demographics["uncertain_return_rejected"] || 0
      @non_uocava_counted = @counted - (@military_counted + @military_dep_counted + @intent_to_return_counted + @uncertain_return_counted)
      @non_uocava_rejected = @rejected - (@military_rejected + @military_dep_rejected + @intent_to_return_rejected + @uncertain_return_rejected)
      
      @uocava_total = @absentee - (@non_uocava_rejected + @non_uocava_counted)
      
      
      
    serializeData: ->
      return {
        voters:  App.ScoreboardsApp.Helpers.numberFormatted(@voters)
        absentee:  App.ScoreboardsApp.Helpers.numberFormatted(@absentee)
        absentee_percent: App.ScoreboardsApp.Helpers.percentFormatted(@absentee, @voters)
        counted: App.ScoreboardsApp.Helpers.numberFormatted(@counted)
        counted_percent: App.ScoreboardsApp.Helpers.percentFormatted(@counted, @absentee)
        rejected: App.ScoreboardsApp.Helpers.numberFormatted(@rejected)
        rejected_percent: App.ScoreboardsApp.Helpers.percentFormatted(@rejected, @absentee)
        uocava_percent:  App.ScoreboardsApp.Helpers.percentFormatted(@uocava_total, @absentee)

        military_counted: App.ScoreboardsApp.Helpers.numberFormatted(@military_counted)
        military_counted_percent: App.ScoreboardsApp.Helpers.percentFormatted(@military_counted, @absentee)
        military_rejected: App.ScoreboardsApp.Helpers.numberFormatted(@military_rejected)
        military_rejected_percent: App.ScoreboardsApp.Helpers.percentFormatted(@military_rejected, @absentee)
        military_dep_counted: App.ScoreboardsApp.Helpers.numberFormatted(@military_dep_counted)
        military_dep_counted_percent: App.ScoreboardsApp.Helpers.percentFormatted(@military_dep_counted, @absentee)
        military_dep_rejected: App.ScoreboardsApp.Helpers.numberFormatted(@military_dep_rejected)
        military_dep_rejected_percent: App.ScoreboardsApp.Helpers.percentFormatted(@military_dep_rejected, @absentee)
        intent_to_return_counted: App.ScoreboardsApp.Helpers.numberFormatted(@intent_to_return_counted)
        intent_to_return_counted_percent: App.ScoreboardsApp.Helpers.percentFormatted(@intent_to_return_counted, @absentee)
        intent_to_return_rejected: App.ScoreboardsApp.Helpers.numberFormatted(@intent_to_return_rejected)
        intent_to_return_rejected_percent: App.ScoreboardsApp.Helpers.percentFormatted(@intent_to_return_rejected, @absentee)
        uncertain_return_counted: App.ScoreboardsApp.Helpers.numberFormatted(@uncertain_return_counted)
        uncertain_return_counted_percent: App.ScoreboardsApp.Helpers.percentFormatted(@uncertain_return_counted, @absentee)
        uncertain_return_rejected: App.ScoreboardsApp.Helpers.numberFormatted(@uncertain_return_rejected)        
        uncertain_return_rejected_percent: App.ScoreboardsApp.Helpers.percentFormatted(@uncertain_return_rejected, @absentee)        

        non_uocava_counted: App.ScoreboardsApp.Helpers.numberFormatted(@non_uocava_counted)
        non_uocava_counted_percent: App.ScoreboardsApp.Helpers.percentFormatted(@non_uocava_counted, @absentee)        

        non_uocava_rejected: App.ScoreboardsApp.Helpers.numberFormatted(@non_uocava_rejected)
        non_uocava_rejected_percent: App.ScoreboardsApp.Helpers.percentFormatted(@non_uocava_rejected, @absentee)        
      }
      
    onShow: ->
      @renderPieChart()
    
    renderPieChart: ->
    
      @pieData = [
        {
          value: @non_uocava_counted
          color: "#00cc7a"
          highlight: "#00cc7a"
          label: "Domestic Counted"
        },
        {
          value: @non_uocava_rejected
          color: "#00aa7a"
          highlight: "#00aa7a"
          label: "Domestic Rejected"
        },
        {
          value: @military_counted
          color: "#cc6633"
          highlight: "#cc6633"
          label: "Military Counted Absentee"
        },
        {
          value: @military_rejected
          color: "#aa6633"
          highlight: "#aa6633"
          label: "Military Rejected Absentee"
        },
        {
          value: @military_dep_counted
          color: "#cc007a"
          highlight: "#cc007a"
          label: "Military Dependent or Spouse Counted"
        },
        {
          value: @military_dep_rejected
          color: "#aa007a"
          highlight: "#aa007a"
          label: "Military Dependent or Spouse Rejected"
        },
        {
          value: @intent_to_return_counted
          color: "#7acccc"
          highlight: "#7acccc"
          label: "Overseas with Intent to Return Counted"
        },
        {
          value: @intent_to_return_rejected
          color: "#7aaaaa"
          highlight: "#7aaaaa"
          label: "Overseas with Intent to Return Rejected"
        },
        {
          value: @uncertain_return_counted
          color: "#007acc"
          highlight: "#007acc"
          label: "Overseas with Uncertain Status Rejected"
        },
        {
          value: @uncertain_return_rejected
          color: "#007aaa"
          highlight: "#007aaa"
          label: "Overseas with Uncertain Status Counted"
        }      
      ]
      
      @pieOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
      
      
      ctx = $("#metadata-uocava-chart").get(0).getContext("2d")
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)
      
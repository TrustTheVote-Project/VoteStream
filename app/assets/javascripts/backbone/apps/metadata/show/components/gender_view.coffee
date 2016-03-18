@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.GenderView extends Marionette.Layout
    template: 'metadata/show/_gender'
    
    regions:
      toggleRegion: '#metadata-gender-toggle'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @genders = @demographics['sex']
      @toggler = { selected: 'voters'}
      
    serializeData: ->
      genders = {}
      gender_total = 0
      for gender, count of @genders
        gender_total += count
        
      for gender, count of @genders        
        genders[@genderLabel(gender)] = App.ScoreboardsApp.Helpers.percentFormatted(count, gender_total)
            
      return {
        genders: genders
        colors: @colors
      }
      
    onShow: ->
      @toggleRegion.show new Show.TotalTypeTogglerView({toggler: @toggler})
      @renderPieChart()

    colors: (gender) ->
      switch gender.toLowerCase()
        when "male"
          "#41aef4"
        when "female"
          "#5a7688"
    
    genderLabel: (gender) ->
      gender_name = gender.toLowerCase()
      gender_name.charAt(0).toUpperCase() + gender_name.slice(1);
    
    renderPieChart: ->
      @pieData = []
      for gender, count of @genders
        @pieData.push
          value: count
          color: @colors(gender)
          label: @genderLabel(gender)

      @pieOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
      
      ctx = $("#metadata-gender-chart").get(0).getContext("2d")
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)
    
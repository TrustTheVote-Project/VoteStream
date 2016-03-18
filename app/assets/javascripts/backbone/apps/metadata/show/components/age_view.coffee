@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.AgeView extends Marionette.Layout
    template: 'metadata/show/_age'
    
    regions:
      toggleRegion: '#metadata-age-toggle'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @ages = []
      currentYear = (new Date()).getFullYear()
      for year, count of @demographics['birth_years']
        year = year.replace(/-.+/, "")
        @ages.push([currentYear - parseInt(year), count])
        
      @toggler = { selected: 'voters'}
      
    onShow: ->
      @toggleRegion.show new Show.TotalTypeTogglerView({toggler: @toggler})
      @renderLineChart()

    colors: (gender) ->
      switch gender.toLowerCase()
        when "male"
          "#41aef4"
        when "female"
          "#5a7688"
    
    genderLabel: (gender) ->
      gender_name = gender.toLowerCase()
      gender_name.charAt(0).toUpperCase() + gender_name.slice(1);
    
    renderLineChart: ->
      sortedAgeCounts = @ages.sort (a,b) ->
        if a[0] < b[0]
          return -1
        else if a[0] == b[0]
          return 0
        else
          return 1
      
      labels =[]
      counts = []
      i = 0
      for age_year in sortedAgeCounts
        if i % 10 == 0
          labels.push(age_year[0])
          counts.push(age_year[1])
        i += 1
      
      data = {
        labels: labels
        datasets: [
          {
            label: "Age"
            data: counts
            fillColor : "rgba(65,174,244,.5)"
            
          } 
        ]
      }
      
      @lineOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
        scaleShowGridLines: false
        #bezierCurve: false
        pointDot: false
      
      ctx = $("#metadata-age-chart").get(0).getContext("2d")
      @lineChart = new Chart(ctx).Line data, @lineOptions

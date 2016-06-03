@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  

  class Show.AgeStatsView extends Marionette.ItemView
    template: 'metadata/show/_age_stats'
    
    initialize: (options) ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @ages = []
      currentYear = (new Date()).getFullYear()
      @toggler = options.toggler
      birth_years = if @toggler.selected == 'voters' then @demographics['birth_years'] else @demographics['birth_years_voted']
      for year, count of birth_years
        year = year.replace(/-.+/, "")
        @ages.push([currentYear - parseInt(year), count])

    serializeData: ->
      stats_header = if @toggler.selected == 'voters' then "All Registrants" else "Participating Voters"
      return {
        stats_header: stats_header
      }    
      
      
    onShow: ->
      @renderLineChart()

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
      
      lineOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
        scaleShowGridLines: false
        #bezierCurve: false
        pointDot: false
      
      id_part = if @toggler.selected == 'voters' then "reg" else "bal"
      ctx = $("#metadata-age-stats-"+id_part+" .line-chart").get(0).getContext("2d")
      @lineChart = new Chart(ctx).Line data, lineOptions

  class Show.AgeView extends Marionette.Layout
    template: 'metadata/show/_age'
      
    regions:
      statsRegionReg: '#metadata-age-stats-reg'
      statsRegionBal: '#metadata-age-stats-bal'
    
    initialize: (options) ->
      @toggler = options.toggler
      @statsViewReg = new Show.AgeStatsView({toggler: {selected: 'voters'}})
      @statsViewBal = new Show.AgeStatsView({toggler: {selected: 'ballots'}})
      
    onShow: ->
      console.log('show')
      @statsRegionReg.show @statsViewReg
      if @toggler.selected == 'ballots'
        @statsRegionBal.show @statsViewBal
    
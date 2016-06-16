@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.RaceStatsView extends Marionette.ItemView
    template: 'metadata/show/_race_stats'

    initialize: (options) ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @races = @demographics['race']
      @voting_races = @demographics['race_voted']
      @toggler = options.toggler
      
      @race_pctgs = []
      @voting_race_pctgs = []
      @race_total = 0
      @voting_race_total = 0
      for item, count of @races
        @race_total += count

      for item, count of @voting_races
        @voting_race_total += count
        
      for item, count of @races        
        @race_pctgs.push
          label: @label(item)
          color: @colors(item)
          percent: App.ScoreboardsApp.Helpers.percentFormatted(count, @race_total)
          count: count
          
      for item, count of @voting_races        
        @voting_race_pctgs.push
          label: @label(item)
          color: @colors(item)
          percent: App.ScoreboardsApp.Helpers.percentFormatted(count, @voting_race_total)
          count: count
            
      @race_pctgs.sort (a,b) ->
        if a.count > b.count
          return -1
        else if a.count == b.count
          return 0
        else
          return 1
        
      @voting_race_pctgs.sort (a,b) ->
        if a.count > b.count
          return -1
        else if a.count == b.count
          return 0
        else
          return 1
      
      
    templateHelpers: =>
      race_pctgs: =>
        if @toggler.selected == 'voters' then @race_pctgs else @voting_race_pctgs
      race_total: =>
        App.ScoreboardsApp.Helpers.numberFormatted(if @toggler.selected == 'voters' then @race_total else @voting_race_total)
      
    serializeData: ->
      stats_header = if @toggler.selected == 'voters' then "All Registrants" else "Participating Voters"
      
      return {
        stats_header: stats_header
        colors: @colors
      }  
      
    onShow: ->
      @renderPieChart()

    colors: (name) ->
      switch name.toLowerCase()
        when "black (not hispanic)"
          "#88ce5a"
        when "white (not hispanic)"
          "#5a7688"
        when "multi-racial"
          "#0000ff"
        when "decline to state"
          "#aaaaaa"
        when "hispanic"
          "#31cefF"
        when "asian / pacific islander"
          "#ce3188"
        when "american indian / alaskan native"
          "#31ce88"
        else
          "#000000"
    
    label: (name) ->
      name = name.toLowerCase()
      name.charAt(0).toUpperCase() + name.slice(1);
    
    renderPieChart: ->
      @pieData = []
      for item, count of @races
        @pieData.push
          value: count
          color: @colors(item)
          label: @label(item)

      @pieOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
      
      id_part = if @toggler.selected == 'voters' then "reg" else "bal"
      ctx = $("#metadata-race-stats-"+id_part+" .pie-chart").get(0).getContext("2d")
      
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)
    
  class Show.RaceView extends Marionette.Layout
    template: 'metadata/show/_race'
  
    regions:
      statsRegionReg: '#metadata-race-stats-reg'
      statsRegionBal: '#metadata-race-stats-bal'
  
    initialize: (options) ->
      @toggler = options.toggler
      @statsViewReg = new Show.RaceStatsView({toggler: {selected: 'voters'}})
      @statsViewBal = new Show.RaceStatsView({toggler: {selected: 'ballots'}})
    
    onShow: ->
      @statsRegionReg.show @statsViewReg
      if @toggler.selected == 'ballots'
        @statsRegionBal.show @statsViewBal
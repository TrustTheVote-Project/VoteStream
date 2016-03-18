@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.RaceView extends Marionette.Layout
    template: 'metadata/show/_race'
    
    regions:
      toggleRegion: '#metadata-race-toggle'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @races = @demographics['race']
      @toggler = { selected: 'voters'}
      
    serializeData: ->
      items = []
      item_total = 0
      for item, count of @races
        item_total += count
        
      for item, count of @races        
        items.push
          label: @label(item)
          color: @colors(item)
          percent: App.ScoreboardsApp.Helpers.percentFormatted(count, item_total)
          count: count
            
      items.sort (a,b) ->
        if a.count > b.count
          return -1
        else if a.count == b.count
          return 0
        else
          return 1
          
      return {
        races: items
        colors: @colors
      }
      
    onShow: ->
      @toggleRegion.show new Show.TotalTypeTogglerView({toggler: @toggler})
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
      
      ctx = $("#metadata-race-chart").get(0).getContext("2d")
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)
    
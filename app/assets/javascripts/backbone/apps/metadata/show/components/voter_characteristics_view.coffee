@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.VoterCharacteristicsView extends Marionette.Layout
    template: 'metadata/show/_voter_characteristics'
    
    regions:
      toggleRegion: '#metadata-voter-characteristics-toggle'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @voter_characteristics = @demographics['voter_characteristics']
      @total_registrants = @demographics['voter_registrations']
      @toggler = { selected: 'voters'}
      
    serializeData: ->
      items = []
      
      for item, count of @voter_characteristics        
        items.push
          label: @label(item)
          percent: App.ScoreboardsApp.Helpers.percentFormatted(count, @total_registrants)
          count: count
            
      items.sort (a,b) ->
        if a.count > b.count
          return -1
        else if a.count == b.count
          return 0
        else
          return 1
          
      i = 0
      for item in items
        item.color = @colors(i, item.count)
        i+= 1
          
      return {
        voter_characteristics: items
        colors: @colors
      }
      
    onShow: ->
      @toggleRegion.show new Show.TotalTypeTogglerView({toggler: @toggler})

    colors: (i, count) ->
      val = parseInt(255 * count / @total_registrants)
      if i % 3 == 0
        return "rgb(#{val}, 50, 50)"
      else if i % 3 == 1
        return "rgb(50, #{val}, 50)"
      else if i % 3 == 2
        return "rgb(50, 50, #{val})"
      
    label: (name) ->
      name = name.toLowerCase()
      name.charAt(0).toUpperCase() + name.slice(1);
    

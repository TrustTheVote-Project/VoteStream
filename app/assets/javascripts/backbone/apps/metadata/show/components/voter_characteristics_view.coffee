@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.VoterCharacteristicsStatsView extends Marionette.ItemView
    template: 'metadata/show/_voter_characteristics_stats'
  
    initialize: (options) ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @voter_characteristics = @demographics['voter_characteristics']
      @voting_voter_characteristics = @demographics['voting_voter_characteristics']
      @total_registrants = @demographics['voter_registrations']
      @total_voters = @demographics['voters']
      @toggler = options.toggler
  
  
    serializeData: ->
      chars = if @toggler.selected == 'voters' then @voter_characteristics else @voting_voter_characteristics
      total = if @toggler.selected == 'voters' then @total_registrants else @total_voters
      stats_header = if @toggler.selected == 'voters' then "All Registrants" else "Participating Voters"
      items = []
      
      for item, count of chars        
        items.push
          label: @label(item)
          percent: App.ScoreboardsApp.Helpers.percentFormatted(count, total)
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
      
    colors: (i, count) ->
      total = if @toggler.selected == 'voters' then @total_registrants else @total_voters
      val = parseInt(255 * count / total)
      if i % 3 == 0
        return "rgb(#{val}, 50, 50)"
      else if i % 3 == 1
        return "rgb(50, #{val}, 50)"
      else if i % 3 == 2
        return "rgb(50, 50, #{val})"
      
    label: (name) ->
      name = name.toLowerCase()
      name.charAt(0).toUpperCase() + name.slice(1);
    
  class Show.VoterCharacteristicsView extends Marionette.Layout
    template: 'metadata/show/_voter_characteristics'
    
    regions:
      statsRegionReg: '#metadata-voter-characteristics-stats-reg'
      statsRegionBal: '#metadata-voter-characteristics-stats-bal'

    initialize: (options) ->
      @toggler = options.toggler
      @statsViewReg = new Show.VoterCharacteristicsStatsView({toggler: {selected: 'voters'}})
      @statsViewBal = new Show.VoterCharacteristicsStatsView({toggler: {selected: 'ballots'}})
    
    onShow: ->
      @statsRegionReg.show @statsViewReg
      if @toggler.selected == 'ballots'
        @statsRegionBal.show @statsViewBal

      

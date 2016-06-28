@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.PartyStatsView extends Marionette.ItemView
    template: 'metadata/show/_party_stats'
    
    initialize: (options) ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @parties = @demographics['party']
      @voting_parties = @demographics['party_voted']
      @toggler = options.toggler
      
    serializeData: ->
      party_data = if @toggler.selected == 'voters' then @parties else @voting_parties
      stats_header = if @toggler.selected == 'voters' then "All Registrants" else "Participating Voters"
      parties = []
      party_total = 0
      for party, count of party_data
        party_total += count
        
      
      for party, count of party_data        
        parties.push([@partyLabel(party), App.ScoreboardsApp.Helpers.percentFormatted(count, party_total), count])
        
      parties.sort (a,b) ->
        if a[2] < b[2]
          return 1
        else if a[2] == b[2]
          return 0
        else
          return -1
        
      return {
        parties: parties
        stats_header: stats_header
        colors: @colors
      }
      

    colors: (name) ->
      switch name.toLowerCase()
        when "democratic", "democrat"
          "rgba(2, 53, 130,1)"
        when "republican", "republic"
          "rgba(220, 21, 33,1)"
        else
          "rgba(100,50,0,1)"
    
    partyLabel: (party) ->
      name = party.toLowerCase()
      name.charAt(0).toUpperCase() + name.slice(1);
      
  class Show.PartyView extends Marionette.Layout
    className: ->
       "stats-layout"
    
    template: 'metadata/show/_party'
  
    regions:
      statsRegionReg: '#metadata-party-stats-reg'
      statsRegionBal: '#metadata-party-stats-bal'

    initialize: (options) ->
      @toggler = options.toggler
      @statsViewReg = new Show.PartyStatsView({toggler: {selected: 'voters'}})
      @statsViewBal = new Show.PartyStatsView({toggler: {selected: 'ballots'}})
      
    onShow: ->
      @statsRegionReg.show @statsViewReg
      if @toggler.selected == 'ballots'
        @statsRegionBal.show @statsViewBal
    
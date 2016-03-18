@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.PartyView extends Marionette.Layout
    template: 'metadata/show/_party'
    
    regions:
      toggleRegion: '#metadata-party-toggle'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @parties = @demographics['party']
      @toggler = { selected: 'voters'}
      
    serializeData: ->
      parties = []
      party_total = 0
      for party, count of @parties
        party_total += count
        
      
      for party, count of @parties        
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
        colors: @colors
      }
      
    onShow: ->
      @toggleRegion.show new Show.TotalTypeTogglerView({toggler: @toggler})

    colors: (name) ->
      switch name.toLowerCase()
        when "democratic"
          "rgba(0,0,255,1)"
        when "republican"
          "rgba(255,0,0,1)"
        else
          "rgba(100,50,0,1)"
    
    partyLabel: (party) ->
      name = party.toLowerCase()
      name.charAt(0).toUpperCase() + name.slice(1);
    
@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.VoterCharacteristicsStatsView extends Marionette.ItemView
    template: 'metadata/show/_voter_characteristics_stats'
  
    initialize: (options) ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @vc = @demographics['voter_characteristics']
      @vc['absentee_total'] =       @absentee = @metaData.get('absentee')
      @vc['absentee_overseas'] =  @vc["is_residing_abroad_uncertain_return"] + @vc["is_residing_abroad_with_intent_to_return"]
      @vc["absentee_military"] = @vc["is_active_duty_uniformed_services"] + @vc["is_eligible_military_spouse_or_dependent"]
      @vc['absentee_domestic'] = @vc['absentee_total'] - (@vc['absentee_overseas'] + @vc['absentee_military'])
      
      @voting_vc = @demographics['voting_voter_characteristics']
      @voting_vc['absentee_total'] =       @absentee = @metaData.get('absentee')
      @voting_vc['absentee_overseas'] =  @voting_vc["is_residing_abroad_uncertain_return"] + @voting_vc["is_residing_abroad_with_intent_to_return"]
      @voting_vc["absentee_military"] = @voting_vc["is_active_duty_uniformed_services"] + @voting_vc["is_eligible_military_spouse_or_dependent"]
      @voting_vc['absentee_domestic'] = @voting_vc['absentee_total'] - (@voting_vc['absentee_overseas'] + @voting_vc['absentee_military'])
      # Same as above
      
      @ordered_characteristics = [
        ["is_citizen", "Citizen"]
        ["is_eighteen_election_day", "Eighteen By Election Day" ]
        ["is_residing_at_registration_address", "Resides at Registration Address"]
        ["absentee_total", "Absentee"]
        ["absentee_domestic", "Domestic Absentee"]
        ["absentee_overseas", "Overseas Absentee"]
        ["absentee_military", "Military Absentee"]
        ["is_residing_abroad_uncertain_return", "Resides Abroad with Uncertain Return"]
        ["is_residing_abroad_with_intent_to_return", "Resides Abroad with Intent To Return"]
        ["is_active_duty_uniformed_services", "Active Duty Uniformed Services"]
        ["is_eligible_military_spouse_or_dependent", "Eligible Military Spouse or Dependent"]
      ]
  
      @total_registrants = @demographics['voter_registrations']
      @total_voters = @demographics['voters']
      @toggler = options.toggler
  
  
    serializeData: ->
      char_vals = if @toggler.selected == 'voters' then @vc else @voting_vc
      total = if @toggler.selected == 'voters' then @total_registrants else @total_voters
      stats_header = if @toggler.selected == 'voters' then "All Registrants" else "Participating Voters"
      items = []
      
      for char_opt in @ordered_characteristics
        count = char_vals[char_opt[0]]
        items.push
          label: char_opt[1]
          percent: App.ScoreboardsApp.Helpers.percentFormatted(count, total)
          count: count
            
      i = 0
      for item in items
        item.color = @colors(i, item.count)
        i+= 1
          
      return {
        voter_characteristics: items
        colors: @colors
        stats_header: stats_header
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

      

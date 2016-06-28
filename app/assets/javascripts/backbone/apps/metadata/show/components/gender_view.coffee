@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.GenderStatsView extends Marionette.ItemView
    template: 'metadata/show/_gender_stats'

    initialize: (options)->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @genders = @demographics['sex']
      @voting_genders = @demographics['sex_voted']
      @toggler = options.toggler
      
      @gender_pctgs = {}
      @voting_gender_pctgs = {}
      @gender_total = 0
      @voting_gender_total = 0
      for gender, count of @genders
        @gender_total += count

      for gender, count of @voting_genders
        @voting_gender_total += count
        
      for gender, count of @genders        
        @gender_pctgs[@genderLabel(gender)] = App.ScoreboardsApp.Helpers.percentFormatted(count, @gender_total)

      for gender, count of @voting_genders        
        @voting_gender_pctgs[@genderLabel(gender)] = App.ScoreboardsApp.Helpers.percentFormatted(count, @voting_gender_total)
      
    templateHelpers: =>
      gender_pctgs: =>
        if @toggler.selected == 'voters' then @gender_pctgs else @voting_gender_pctgs
      gender_total: =>
        App.ScoreboardsApp.Helpers.numberFormatted(if @toggler.selected == 'voters' then @gender_total else @voting_gender_total)
        
    serializeData: ->
      stats_header = if @toggler.selected == 'voters' then "All Registrants" else "Participating Voters"
      
      return {
        stats_header: stats_header
        colors: @colors
      }
      
    onShow: ->
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
      gHash = if @toggler.selected == 'voters' then @genders else @voting_genders
      for gender, count of gHash
        @pieData.push
          value: count
          color: @colors(gender)
          label: @genderLabel(gender)

      @pieOptions =
        customTooltips: (tooltip) ->  # don't show a tooltip
          return;
      
      id_part = if @toggler.selected == 'voters' then "reg" else "bal"
      ctx = $("#metadata-gender-stats-"+id_part+" .pie-chart").get(0).getContext("2d")
      @pieChart = new Chart(ctx).Pie(@pieData, @pieOptions)
    

  class Show.GenderView extends Marionette.Layout
    className: ->
       "stats-layout"
       
    template: 'metadata/show/_gender'
    
    regions:
      statsRegionReg: '#metadata-gender-stats-reg'
      statsRegionBal: '#metadata-gender-stats-bal'
    
    initialize: (options) ->
      @toggler = options.toggler
      @statsViewReg = new Show.GenderStatsView({toggler: {selected: 'voters'}})
      @statsViewBal = new Show.GenderStatsView({toggler: {selected: 'ballots'}})
      
    onShow: ->
      @statsRegionReg.show @statsViewReg
      if @toggler.selected == 'ballots'
        @statsRegionBal.show @statsViewBal
    

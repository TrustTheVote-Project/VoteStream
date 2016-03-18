@App.module "ScoreboardsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class CandidateRow extends Marionette.ItemView
    template: 'scoreboards/list/_candidate_row'
    tagName: 'div'
    className: ->
      classes = ["row-fluid","candidate"]
      classes.push('extra') if @options.extra
      classes.push('hide') if @options.hidden
      classes.push('winner') if @options.winner
      return classes.join(' ')
    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      data.totalVotes = @options.totalVotes
      data.showVotingMethod = @options.showVotingMethod
      data
    templateHelpers:
      percent: -> App.ScoreboardsApp.Helpers.percent(@votes, @totalVotes)
      percentFormatted: -> App.ScoreboardsApp.Helpers.percentFormatted(@votes, @totalVotes)
      voteChannels: -> 
        @vote_channels || {}
      channelLabel: (channel) -> 
        cData = @vote_channels[channel]
        label = switch channel
          when 'election-day'
            "Election Day"
          when 'absentee'
            "Absentee"
          when 'early'
            "Early"
        return label + ' ' + App.ScoreboardsApp.Helpers.percentFormatted(cData, @votes)
        
    onShow: ->
      c = @model.get('c')
      if @model.get('party')['abbr'] == 'stats'
        $(".party", @$el).text('')
      if @model.get('np') and @options.excludeNP
        $(".bar", @$el).hide()
        $(".percent", @$el).text($(".votes", @$el).text())
        $(".votes", @$el).hide()

      $("h5, .percent", @$el).css(color: c)
      $(".filler", @$el).css(background: c)
      $('[data-toggle="tooltip"]', @$el).tooltip();

  # A common class for shared Contest/Referendum ResultView logic
  class BaseResultView extends Marionette.CompositeView
    
    # Requires @district and @ui.mapContainer to be defined in the subclass.
    toggleMapView: () ->
      @ui.mapContainer.toggleClass('hidden')
      
      if !@mapViewInstance
        PrecinctColors = App.module('Entities').PrecinctColors
        colors = new PrecinctColors
        si = App.request 'entities:scoreboardInfo'
        colors.fetchForResult(@model, @region, si.get('advanced')).done () =>
          @mapRegion = new Marionette.Region
            el: @ui.mapContainer

          @mapViewInstance = new App.ScoreboardsApp.Show.MapView
            zoomLevel: 12
            hideControls:     true
            whiteBackground:  false
            noZoom:           false
            noPanning:        false
            infoWindow:       'simple'
            staticColors:     colors
          @mapRegion.show  @mapViewInstance
    

  class ContestResultView extends BaseResultView
    template: 'scoreboards/list/_contest_result'
    className: -> "contest result"

    itemView: CandidateRow
    itemViewContainer: 'div.candidates'
    itemViewOptions: (model, i) ->
      stats = model.get('party')['abbr'] == 'stats'
      excludeNP = @options.excludeNP
      # hidden if this is stats and excludeNP OR
      # hidden if this is NOT stats and i > 1
      hidden = (stats and excludeNP) or (!stats and i > 1)      
      return {
        model:             model
        extra:             !stats and i > 1
        hidden:            hidden
        winner:            i is 0 and gon.percentReporting is 'Final Results'
        totalVotes:        @options.totalVotes
        excludeNP:         excludeNP,
        showVotingMethod:  @options.showVotingMethod && !stats
      }

    ui:
      rowsList: 'div.candidates'
      partInfo: 'div.participaction-info'
      showMoreBtn: '#js-show-more'
      showLessBtn: '#js-show-less'
      mapToggle: '.map-toggle'
      mapContainer: '.map-container'

    events:
      'click #js-show-more': (e) ->
        e.preventDefault()
        $('.candidate.extra', @ui.rowsList).show()
        @ui.showMoreBtn.hide()
        @ui.showLessBtn.show()

      'click #js-show-less': (e) ->
        e.preventDefault()
        $('.candidate.extra', @ui.rowsList).hide()
        @ui.showLessBtn.hide()
        @ui.showMoreBtn.show()
      
      'click .map-toggle': (e) ->
        e.preventDefault()
        @ui.mapToggle.toggleClass('active')
        this.toggleMapView()

    initialize: (opts) ->
      @model = opts.model
      @region = opts.region

    onShow: ->
      if @collection.length > 2 and !@options.simpleVersion
        @ui.showMoreBtn.show()


  class ResponseRow extends Marionette.ItemView
    template: 'scoreboards/list/_response_row'
    tagName: 'div'
    className: 'row-fluid response'
    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      data.totalVotes = @options.totalVotes
      data
    templateHelpers:
      percent: -> App.ScoreboardsApp.Helpers.percent(@votes, @totalVotes)
      percentFormatted: -> App.ScoreboardsApp.Helpers.percentFormatted(@votes, @totalVotes)      
    onShow: ->
      c = @model.get('c')
      $("td", @$el).css(color: c)

      if @model.get('np') and @options.excludeNP
        $(".bar", @$el).hide()
        $(".percent", @$el).text($(".votes", @$el).text())
        $(".votes", @$el).hide()

  class ReferendumResultView extends BaseResultView
    template: 'scoreboards/list/_referendum_result'
    className: -> "referendum result"

    itemView: ResponseRow
    itemViewContainer: 'div.content'
    itemViewOptions: (model, i) ->
      return {
        model: model,
        totalVotes: @options.totalVotes,
        excludeNP: @options.excludeNP
      }
      
    ui:
      mapToggle: '.map-toggle'
      mapContainer: '.map-container'
    
    events:
      'click .map-toggle': (e) ->
        e.preventDefault()
        @ui.mapToggle.toggleClass('active')
        this.toggleMapView()

    initialize: (opts) ->
      @model = opts.model
      @region = opts.region

  class List.ResultsView extends Marionette.CompositeView
    template: 'scoreboards/list/_results'
    itemView: ContestResultView
    itemViewContainer: '#results'

    modelEvents:
      "change:percentageType": 'render'
      "change:showParticipation": 'render'
      "change:showVotingMethod": 'render'

    collectionEvents:
      sync: 'render'

    initialize: (opts) ->
      @model = App.request 'entities:scoreboardInfo'
      @.listenTo @model.get('precinctResults'), 'sync', => @render()

    itemViewOptions: (model, i) ->
      summary = model.get('summary')

      totalVotes = if @model.get('percentageType') == 'voters' then summary.get('voters') else summary.get('ballots')

      return {
        model:             model
        totalVotes:        totalVotes
        excludeNP:         @model.get('percentageType') == 'ballots'
        selected:          false
        showParticipation: @model.get('showParticipation')
        showVotingMethod:  @model.get('showVotingMethod')
        region:            @model.get('region')
        collection:        model.get('summary').get('rows') }

    getItemView: (model) ->
      if model.get('type') == 'c'
        ContestResultView
      else
        ReferendumResultView

  # Participation stats panel
  class ParticipationStatsView extends Marionette.ItemView
    template: 'scoreboards/list/_participation_stats'
    id: 'participation-info'
    className: 'row-fluid result'
    modelEvents:
      'change:showParticipation': 'render'
      'change:percentageType': 'render'
      'change:precinctsReportingCount': 'render'
      'change:totalRegisteredVoters': 'render'
      'change:totalBallotsCast': 'render'
      'change:electionDayVotes': 'render'
      'change:earlyVotes': 'render'
      'change:absenteeVotes': 'render'
      'change:npVotes': 'render'

    serializeData: ->
      data = Backbone.Marionette.ItemView.prototype.serializeData.apply @, arguments
      totalBallots = @model.get('totalBallotsCast')
      totalRegisteredVoters = @model.get('totalRegisteredVoters')
      data.turnOut = Math.round((totalBallots / (totalRegisteredVoters || 1)) * 100)

      percentageDenom = switch @model.get('percentageType')
        when 'voters'
          totalRegisteredVoters
        when 'ballots'
          totalBallots
        else
          console.error('Unhandled percentageType:' + @model.get('percentageType')) if console?
          0

      percentFormatted = App.ScoreboardsApp.Helpers.percentFormatted

      data.electionDayPercent = percentFormatted(@model.get('electionDayVotes'), percentageDenom)
      data.earlyPercent = percentFormatted(@model.get('earlyVotes'), percentageDenom)
      data.absenteePercent = percentFormatted(@model.get('absenteeVotes'), percentageDenom)

      # Denominating NP votes by number of ballots doesn't make sense
      if @model.get('percentageType') == 'voters'
        data.npPercent = percentFormatted(@model.get('npVotes'), percentageDenom)
      else
        data.npPercent = null

      data

    onRender: ->
      if @model.get('showParticipation')
        @$el.removeClass 'hide'
      else
        @$el.addClass 'hide'


  # Results section layout
  class List.ResultsLayout extends Marionette.Layout
    template: 'scoreboards/list/_results_layout'
    id: 'results-layout'

    regions:
      participationStatsRegion:     '#participation-stats-region'
      resultsViewRegion:            '#results-view-region'

    modelEvents:
      'change:showParticipation': 'setResultsWidth'

    initialize: ->
      @si = App.request 'entities:scoreboardInfo'
      @model = @si
      @results = @si.get 'results'

    setResultsWidth: ->
      $results = this.$(@regions.resultsViewRegion)
      fullWidth = 'col-sm-12'
      halfWidth = 'col-sm-6  col-sm-pull-6'
      if @model.get('showParticipation')
        $results.addClass(halfWidth)
        $results.removeClass(fullWidth)
      else
        $results.addClass(fullWidth)
        $results.removeClass(halfWidth)

    onShow: ->
      @resultsViewRegion.show new List.ResultsView
        collection: @results

      @participationStatsRegion.show new ParticipationStatsView
        model: @si
      
      this.setResultsWidth()


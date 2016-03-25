@App.module "ScoreboardsApp.MapList", (MapList, App, Backbone, Marionette, $, _) ->

  class MapList.View extends Marionette.Layout
    template: 'scoreboards/map_list/view'
    id: 'map_list'

    # regions:
      #filterBarRegion:              '#filter-bar-region'
      #mapListRegion:                '#map-list-region'

    initialize: ->
      @si = App.request 'entities:scoreboardInfo'
      @su = App.request 'entities:scoreboardUrl'
      @saved_maps = App.request "entities:savedMaps"

    selectedMaps: ->
      mapIds = []
      $(".map-saved-items input[type=checkbox]:checked").each (idx, el) ->
        mapIds.push(parseInt($(el).val()))
      mapIds

    previewedMaps: ->
      @previewed_maps || []

    deleteSelected: ->
      @saved_maps.deleteIds(@selectedMaps())  

    previewSelected: ->
      previewed_maps = []
      $(".saved-map-list-item input[type=checkbox]:checked").each (idx, el) ->
        previewed_maps.push(parseInt($(el).val()))
      @previewed_maps = previewed_maps
      @render()
        

    compareSelected: ->
      @su.setComparisonView(@selectedMaps())

    isSelected: (mapId) ->
      @selectedMaps().includes(mapId)
      
    isPreviewed: (mapId) ->
      @previewedMaps().includes(mapId)
      

    templateHelpers: ->
      saved_count: App.request("entities:savedMaps").count()
      maps: App.request("entities:savedMaps").maps()
      mapsSelected: => 
        @selectedMaps().length > 0
        
      percent: -> App.ScoreboardsApp.Helpers.percent(@votes, @totalVotes)
      percentFormatted: -> App.ScoreboardsApp.Helpers.percentFormatted(@votes, @totalVotes)
      isSelected: (id) => @isSelected(id)
      isPreviewed: (id) => @isPreviewed(id)
    
    maps: ->
      @saved_maps.maps()
    
    onRender: ->
      @showMaps()

    # onShow: ->
    #   @showMaps()
      
    showMaps: ->
      waitingFor = []
      waitingFor.push App.request('entities:refcons')
      waitingFor.push App.request('entities:districts')
      waitingFor.push App.request('entities:precincts')

      App.execute 'when:fetched', waitingFor, =>
        for map in @maps()
          filters = map.getFilters()
        
          extraOpts = {
            channel_early: filters.channelEarly,
            channel_electionday: filters.channelElectionday,
            channel_absentee: filters.channelAbsentee
          }
        
          advanced = null #get from url if it matches a different one
        
          resultsColl = new App.Entities.ResultsCollection
          resultsColl.fetchForFilter(gon.locality_id, filters.region, filters.refcon, extraOpts, advanced)
          
          @listenTo resultsColl, 'reset', ((map, filters, advanced, results)->
            result = null # Specific selecte result / contesnt ?
            result = result || results.first()

            precinctResults = new App.Entities.PrecinctResultData
            precinctResults.fetchForResult result, filters.region, extraOpts, advanced

            precinctColors = new App.Entities.PrecinctColors
            precinctColors.fetchForResult result, filters.region, advanced
            
            @addRegion("newMapRegion", "#map-region-#{map.id}")
            @newMapRegion.show new App.ScoreboardsApp.Show.MapView
              infoWindow: 'simple'
              noPanning: false
              precinctResults: precinctResults
              precinctColors:  precinctColors
              precincts: App.request 'entities:precincts'
              coloringType: filters.coloringType || 'results'
          ).bind(this, map, filters, advanced)
          
          
          
    events:
      'click a.map-link': (e) ->
        url = $(e.currentTarget).attr('href')
        App.navigate url, true
      'click input[type=checkbox]': (e) ->
        @render()
      'click #js-delete-selected': (e) ->
        @deleteSelected()
        @render()
      'click #js-preview-selected': (e) ->
        @previewSelected()
      'click #js-view-back': (e) -> window.history.back()
      'click #js-compare-selected': (e) -> 
        e.preventDefault()
        @compareSelected()
      
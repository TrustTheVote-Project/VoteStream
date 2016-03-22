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

    deleteSelected: ->
      @saved_maps.deleteIds(@selectedMaps())  

    compareSelected: ->
      @su.setComparisonView(@selectedMaps())

    isSelected: (mapId) ->
      isSel = @selectedMaps().includes(mapId)
      return isSel

    templateHelpers: ->
      saved_count: App.request("entities:savedMaps").count()
      maps: App.request("entities:savedMaps").maps()
      mapsSelected: => 
        @selectedMaps().length > 0
        
      percent: -> App.ScoreboardsApp.Helpers.percent(@votes, @totalVotes)
      percentFormatted: -> App.ScoreboardsApp.Helpers.percentFormatted(@votes, @totalVotes)
      isSelected: (id) => @isSelected(id)
    

    # onShow: ->
    #  console.log(@saved_maps.maps())
    #   @mapListRegion.show new MapList.ListLayout
    #   @filterBarRegion.show new App.ScoreboardsApp.FilterBar.View
    #     model: @si

    events:
      'click a.map-link': (e) ->
        url = $(e.currentTarget).attr('href')
        App.navigate url, true
      'click input[type=checkbox]': (e) ->
        @render()
      'click #js-delete-selected': (e) ->
        @deleteSelected()
        @render()
      'click #js-view-back': (e) -> window.history.back()
      'click #js-compare-selected': (e) -> 
        e.preventDefault()
        @compareSelected()
      
@App.module "ScoreboardsApp.MapList", (MapList, App, Backbone, Marionette, $, _) ->

  class MapList.View extends Marionette.Layout
    template: 'scoreboards/map_list/view'
    id: 'map_list'

    # regions:
      #filterBarRegion:              '#filter-bar-region'
      #mapListRegion:                '#map-list-region'

    initialize: ->
      @si = App.request 'entities:scoreboardInfo'
      @saved_maps = App.request "entities:savedMaps"

    templateHelpers: ->
      saved_count: App.request("entities:savedMaps").count()
      maps: App.request("entities:savedMaps").maps()   
      percent: -> App.ScoreboardsApp.Helpers.percent(@votes, @totalVotes)
      percentFormatted: -> App.ScoreboardsApp.Helpers.percentFormatted(@votes, @totalVotes)

      

    # onShow: ->
    #  console.log(@saved_maps.maps())
    #   @mapListRegion.show new MapList.ListLayout
    #   @filterBarRegion.show new App.ScoreboardsApp.FilterBar.View
    #     model: @si

    events:
      'click a.map-link': (e) ->
        url = $(e.currentTarget).attr('href')
        App.navigate url, true

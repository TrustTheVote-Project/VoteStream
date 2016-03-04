@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  
  class Entities.SavedMaps
    constructor: ->
      @storage = window.localStorage
    
    maps: ->
      JSON.parse(@storage.getItem('saved_maps') || '[]')
      
    count: ->
      @maps().length

    add_map: (url) ->
      maps = @maps()
      maps.push({url: url})
      @storage.setItem('saved_maps', JSON.stringify(maps))
      

  API =
    getSavedMaps: ->
      unless Entities.savedMaps?
        Entities.savedMaps = new Entities.SavedMaps

      Entities.savedMaps

  App.reqres.setHandler 'entities:savedMaps', -> API.getSavedMaps()


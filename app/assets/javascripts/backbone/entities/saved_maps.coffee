@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.SavedMap
    constructor: (obj) ->
      @mapObj = obj
      @name = obj.name
      @url = obj.url
      
    getName: () ->
      n = @mapObj.name || @mapObj.url
      return n
    
  
  class Entities.SavedMaps
    constructor: ->
      @storage = window.localStorage
    
    maps: ->
      maps = JSON.parse(@storage.getItem('saved_maps') || '[]')
      mapInstances = []
      for map in maps
        mapInstances.push(new Entities.SavedMap(map))
        
      mapInstances
      
      
    count: ->
      @maps().length

    getMapName: (name, list, i) ->
      i = i || 0
      if i != 0
        newName = "#{name} (#{i})"
      else 
        newName = name
      for map in list
        if map.getName() == newName
          i += 1
          return @getMapName(name, list, i)

      return newName

    add_map: (url, name) ->
      maps = @maps()
      # Check if @maps include something with this name
      name = @getMapName(name, maps)
      maps.push({url: url, name: name})
      @storage.setItem('saved_maps', JSON.stringify(maps))
      

    clearMaps: ->
      @storage.setItem('saved_maps', JSON.stringify([]))
    

  API =
    getSavedMaps: ->
      unless Entities.savedMaps?
        Entities.savedMaps = new Entities.SavedMaps

      Entities.savedMaps

  App.reqres.setHandler 'entities:savedMaps', -> API.getSavedMaps()


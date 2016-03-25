@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.SavedMap
    constructor: (obj) ->
      @mapObj = obj
      @name = obj.name
      @url = obj.url
      @id = obj.id
      
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
      
    setMaps: (maps)->
      mapObjs = []
      for map in maps
        mapObjs.push(map.mapObj)
      @storage.setItem('saved_maps', JSON.stringify(mapObjs))
      
      
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

    nextId: (list) ->
      ids = [0]
      for map in list
        ids.push(map.id || 0)
        
      console.log(ids)
      Math.max.apply(Math, ids) + 1
      
      
    deleteIds: (idList) ->
      newList = []
      maps = @maps()
      for map in maps
        if !idList.includes(map.id)
          newList.push(map.mapObj)
      @storage.setItem('saved_maps', JSON.stringify(newList))
      
    
    add_map: (url, name) ->
      maps = @maps()
      # Check if @maps include something with this name
      name = @getMapName(name, maps)
      id = @nextId(maps)
      console.log(id)
      maps.push(new Entities.SavedMap({url: url, name: name, id: id}))
      @setMaps(maps)

    clearMaps: ->
      @storage.setItem('saved_maps', JSON.stringify([]))
    

  API =
    getSavedMaps: ->
      unless Entities.savedMaps?
        Entities.savedMaps = new Entities.SavedMaps

      Entities.savedMaps

  App.reqres.setHandler 'entities:savedMaps', -> API.getSavedMaps()

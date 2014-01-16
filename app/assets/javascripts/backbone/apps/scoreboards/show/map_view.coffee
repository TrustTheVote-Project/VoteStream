@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.MapView extends Marionette.ItemView
    template: 'scoreboards/show/_map'
    id: 'map'

    initialize: ->
      @polygons = []

      si = App.request 'entities:scoreboardInfo'
      @precinctResults = si.get 'precinctResults'
      @precinctResults.on 'sync', => @updateColors()

    updateColors: ->
      items     = @precinctResults.get 'items'
      precincts = @precinctResults.get 'precincts'

      for p in @polygons
        res = precincts.get p.data.precinctId
        p.data.colors = @precinctColors items, res
        p.setOptions
          fillColor:   p.data.colors.fillColor
          fillOpacity: p.data.colors.fillOpacity

    onShow: ->
      @initMap()
      @renderPrecincts()

    initMap: ->
      center = new google.maps.LatLng gon.mapCenterLat, gon.mapCenterLon
      @map = new google.maps.Map @el,
        center:                 center
        zoom:                   gon.mapZoom
        mapTypeControl:         true
        mapTypeControlOptions:
          style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
        navigationControl:      true
        mapTypeId:              google.maps.MapTypeId.ROADMAP

      style = [{
          featureType: 'all'
          stylers: [ saturation: -99 ]
        }, {
          featureType: 'poi',
          stylers: [ visibility: 'off' ]
        }, {
          featureType: 'road',
          stylers: [ visibility: 'off' ]
        }]

      styledMapType = new google.maps.StyledMapType style,
        map:  @map
        name: 'Styled Map'

      @map.mapTypes.set 'map-style', styledMapType
      @map.setMapTypeId 'map-style'

    pointFromPair: (pair) ->
      coords = pair.split(',')
      new google.maps.LatLng parseFloat(coords[1]), parseFloat(coords[0])

    pointsFromKml: (kmls) ->
      for kml in kmls
        @pointFromPair(pair) for pair in kml.split(' ')

    removePreviousPolygons: =>
      poly.setMap(null) for poly in @polygons
      @polygons = []

    colorRange: (colorId) ->
      if colorId == 'Republican' or colorId == 'YES'
        gon.partyColors.republican
      else if colorId == 'Democratic-Farmer-Labor' or colorId == 'NO'
        gon.partyColors.democrat
      else
        gon.partyColors.other

    colorShade: (range, itemVotes, precinctVotes) ->
      p = itemVotes * 100 / precinctVotes
      if p < 0.5
        c = 0
      else if p < 0.6
        c = 1
      else if p < 0.7
        c = 2
      else
        c = 3

      range[c]

    precinctColors: (items, precinctResult) ->
      # Default (not in range precinct) colors are all the same
      fillColor        = '#ffffff'
      fillOpacity      = 0.4
      hoverColor       = fillColor
      hoverOpacity     = 0.4

      if precinctResult?
        # Highlight with opacity if precinct is in range
        hoverOpacity = 0.9
        fillOpacity  = 0.7

        precinctVotes = precinctResult.get('votes')
        if precinctVotes == 0
          # Precinct is not reporting
          fillColor = '#cccccc'
        else
          rows = precinctResult.get('rows')
          leader = items.get precinctResult.get 'leader'
          leaderVotes = precinctResult.get 'leader_votes'
          colorId  = leader?.get('party') or leader?.get('name')

          colorRange = @colorRange colorId
          fillColor = @colorShade colorRange, leaderVotes, precinctVotes
          hoverColor = fillColor

      return {
        fillColor:        fillColor
        fillOpacity:      fillOpacity
        hoverFillColor:   hoverColor
        hoverFillOpacity: hoverOpacity
      }

    renderPrecincts: ->
      precincts = App.request 'entities:precincts'
      App.execute 'when:fetched', precincts, =>
        @removePreviousPolygons()

        bounds  = new google.maps.LatLngBounds()
        results = @precinctResults.get 'precincts'
        items   = @precinctResults.get 'items'

        for precinct in precincts.models
          precinctId = precinct.get 'id'
          res = results.get precinctId
          kml = precinct.get 'kml'
          colors = @precinctColors(items, res)

          lines = @pointsFromKml(kml)

          for points in lines
            bounds.extend(point) for point in points

          poly = new google.maps.Polygon
            paths:          lines,
            strokeColor:    '#ffffff'
            strokeOpacity:  1
            strokeWeight:   .7
            fillColor:      colors.fillColor
            fillOpacity:    colors.fillOpacity
            data:
              precinctId:       precinctId
              colors:           colors

          google.maps.event.addListener poly, 'mouseover', ->
            # return if this == selectedPolygon
            @setOptions
              fillColor:   @.data.colors.hoverFillColor
              fillOpacity: @.data.colors.hoverFillOpacity

          google.maps.event.addListener poly, 'mouseout', ->
            # return if this == selectedPolygon
            @setOptions
              fillColor:   @.data.colors.fillColor
              fillOpacity: @.data.colors.fillOpacity

          @polygons.push poly
          poly.setMap @map

        @map.fitBounds bounds

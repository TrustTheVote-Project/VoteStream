@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.MapView extends Marionette.ItemView
    template: 'scoreboards/show/_map'
    id: 'map'

    initialize: ->
      @polygons = []

      si = App.request 'entities:scoreboardInfo'
      res = si.get 'results'
      res.on 'sync', => @updateColors()

    updateColors: ->
      si = App.request 'entities:scoreboardInfo'
      res = si.get 'results'
      candidates = res.get 'candidates'
      precinctResults = res.get 'precinctResults'

      for p in @polygons
        res = precinctResults?.get p.data.precinctId
        p.data.colors = @precinctColors candidates, res
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

    pointsFromKml: (kml) ->
      @pointFromPair(pair) for pair in kml.split(' ')

    removePreviousPolygons: =>
      poly.setMap(null) for poly in @polygons
      @polygons = []

    partyColorRange: (party) ->
      if party == 'Republican'
        gon.partyColors.republican
      else if party == 'Democratic-Farmer-Labor'
        gon.partyColors.democrat
      else
        gon.partyColors.other

    colorShade: (range, candidateVotes, precinctVotes) ->
      p = candidateVotes * 100 / precinctVotes
      if p < 0.5
        c = 0
      else if p < 0.6
        c = 1
      else if p < 0.7
        c = 2
      else
        c = 3

      range[c]

    precinctColors: (candidates, precinctResult) ->
      # Default (not in range precinct) colors are all the same
      fillColor        = '#000000'
      fillOpacity      = 0.3
      hoverColor       = fillColor
      hoverOpacity     = 0.3

      if precinctResult?
        # Highlight with opacity if precinct is in range
        hoverOpacity = 0.8

        precinctVotes = precinctResult.get('votes')
        if precinctVotes == 0
          # Precinct is not reporting
          fillColor = '#cccccc'
        else
          rows = precinctResult.get('rows')
          leadingResult = rows.first()
          candidate = candidates.get leadingResult.get 'cid'
          party = candidate.get 'party'

          colorRange = @partyColorRange party
          fillColor = @colorShade colorRange, candidate.get('votes'), precinctVotes
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

        bounds = new google.maps.LatLngBounds()

        si = App.request 'entities:scoreboardInfo'
        precinctResults = si.get('results').get('precinctResults')
        candidates = si.get('results').get('candidates')

        for precinct in precincts.models
          precinctId = precinct.get 'id'
          res = precinctResults?.get 'id'
          kml = precinct.get 'kml'
          colors = @precinctColors(candidates, res)

          points = @pointsFromKml(kml)
          bounds.extend(point) for point in points

          poly = new google.maps.Polygon
            paths:          points,
            strokeColor:    '#000000'
            strokeOpacity:  0.3
            strokeWeight:   1
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

        # make extra zoom step to show a bigger map
        do (map = @map) ->
          google.maps.event.addListenerOnce map, 'zoom_changed', ->
            map.setZoom map.getZoom() + 1

        @map.fitBounds bounds

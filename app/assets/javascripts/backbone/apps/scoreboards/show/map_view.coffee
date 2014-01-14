@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.MapView extends Marionette.ItemView
    template: 'scoreboards/show/_map'
    id: 'map'

    initialize: ->
      @polygons = []

      si = App.request 'entities:scoreboardInfo'
      si.on 'change:region', =>
        @highlightRegion si.get('region')

      res = si.get 'results'
      res.on 'sync', => @updateColors()

    updateColors: ->
      si = App.request 'entities:scoreboardInfo'
      res = si.get 'results'
      candidates = res.get 'candidates'
      precinctResults = res.get 'precinctResults'

      for p in @polygons
        res = precinctResults.get p.data.precinctId
        p.data.colors = @precinctColors candidates, res
        @rehighlight p


    rehighlight: (p) ->
      p.setOptions
        fillColor:   if p.data.highlighted then p.data.colors.highlightColor else p.data.colors.fillColor
        fillOpacity: if p.data.highlighted then p.data.colors.highlightOpacity else p.data.colors.fillOpacity

    highlightPolygon: (p) ->
      p.data.highlighted = true
      @rehighlight p

    unhighlightPolygon: (p) ->
      p.data.highlighted = false
      @rehighlight p

    highlightRegion: (region) ->
      if !region?
        pids = 'all'
      else if region instanceof App.Entities.District
        pids = region.get('pids')
      else
        pids = [ region.get('id') ]

      for p in @polygons
        if pids == 'all' or pids.indexOf(p.data.precinctId) != -1
          @highlightPolygon p
        else
          @unhighlightPolygon p

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
      ho = 0.5

      rows = precinctResult?.get('rows')
      if !rows or rows.length == 0
        # not reporting
        hc = '#cccccc'
      else
        leadingResult = rows.first()
        candidate = candidates.get leadingResult.get 'cid'
        party = candidate.get 'party'

        colorRange = @partyColorRange party
        hc = @colorShade colorRange, candidate.get('votes'), precinctResult.get('votes')

      return {
        fillColor:        '#000000'
        fillOpacity:      0.3
        hoverFillColor:   hc
        hoverFillOpacity: 0.8
        highlightColor:   hc
        highlightOpacity: ho
      }

    renderPrecincts: ->
      precincts = App.request 'entities:precincts'
      App.execute 'when:fetched', precincts, =>
        @removePreviousPolygons()

        bounds = new google.maps.LatLngBounds()

        si = App.request 'entities:scoreboardInfo'
        precinctResults = si.get('results').get('precinctResults')
        candidates = si.get('results').get('candidates')

        console.log precinctResults
        for precinct in precincts.models
          precinctId = precinct.get 'id'
          res = precinctResults.get 'id'
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
            hl = @.data.highlighted
            @setOptions
              fillColor:   if hl then @.data.colors.highlightColor else @.data.colors.fillColor
              fillOpacity: if hl then @.data.colors.highlightOpacity else @.data.colors.fillOpacity

          @polygons.push poly
          poly.setMap @map

        @map.fitBounds bounds
        @highlightRegion null

@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.MapView extends Marionette.ItemView
    template: 'scoreboards/show/_map'
    id: 'map'

    initialize: ->
      @polygons = []

      si = App.request 'entities:scoreboardInfo'
      si.on 'change:region', =>
        @highlightRegion si.get('region')

    highlightPolygon: (p) ->
      p.data.highlighted = true
      p.setOptions
        fillColor:   p.data.highlightColor
        fillOpacity: p.data.highlightOpacity

    unhighlightPolygon: (p) ->
      p.data.highlighted = false
      p.setOptions
        fillColor:   p.data.fillColor
        fillOpacity: p.data.fillOpacity

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

    renderPrecincts: ->
      precincts = App.request 'entities:precincts'
      App.execute 'when:fetched', precincts, =>
        @removePreviousPolygons()

        bounds = new google.maps.LatLngBounds()

        for result in precincts.models
          precinctId = result.get 'id'
          precinct = precincts.get precinctId
          kml = precinct.get('kml')

          points = @pointsFromKml(kml)
          bounds.extend(point) for point in points

          fillColor        = '#000000'
          fillOpacity      = 0.3
          hoverFillColor   = fillColor
          hoverFillOpacity = 0.5
          highlightColor   = '#cccc00'
          highlightOpacity = 0.8

          poly = new google.maps.Polygon
            paths:          points,
            strokeColor:    '#000000'
            strokeOpacity:  0.3
            strokeWeight:   1
            fillColor:      fillColor
            fillOpacity:    fillOpacity
            data:
              fillColor:   fillColor
              fillOpacity: fillOpacity
              precinctId:  precinctId
              highlightColor: highlightColor
              highlightOpacity: highlightOpacity

          google.maps.event.addListener poly, 'mouseover', ->
            # return if this == selectedPolygon
            @setOptions
              fillColor:   hoverFillColor
              fillOpacity: hoverFillOpacity

          google.maps.event.addListener poly, 'mouseout', ->
            # return if this == selectedPolygon
            hl = @.data.highlighted
            @setOptions
              fillColor:   if hl then @.data.highlightColor else @.data.fillColor
              fillOpacity: if hl then @.data.highlightOpacity else @.data.fillOpacity

          @polygons.push poly
          poly.setMap @map

        @map.fitBounds bounds
        @highlightRegion null

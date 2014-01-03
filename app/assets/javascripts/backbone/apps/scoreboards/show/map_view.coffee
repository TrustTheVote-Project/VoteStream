@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.MapView extends Marionette.ItemView
    template: 'scoreboards/show/_map'
    id: 'map'

    initialize: (options = {}) ->
      throw new Error 'Results are required' unless options.results
      @results = options.results
      @polygons = []

    onShow: ->
      @initMap()

      @results.on 'reset', =>
        @renderResults()

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

    renderResults: ->
      geos = App.request 'entities:precinctsGeometries'
      App.execute 'when:fetched', [ geos, @results ], =>
        @removePreviousPolygons()

        bounds = new google.maps.LatLngBounds()

        for result in @results.models
          precinctId = result.get 'id'
          geo = geos.get precinctId
          kml = geo.get('kml')

          points = @pointsFromKml(kml)
          bounds.extend(point) for point in points

          fillColor        = '#000000'
          fillOpacity      = 0.3
          hoverFillColor   = fillColor
          hoverFillOpacity = 0.5
          clickFillColor   = '#cccc00'
          clickFillOpacity = 0.8

          poly = new google.maps.Polygon
            paths:          points,
            strokeColor:    '#000000'
            strokeOpacity:  0.3
            strokeWeight:   1
            fillColor:      fillColor
            fillOpacity:    fillOpacity
            data:
              fillColor: fillColor
              fillOpacity: fillOpacity

          google.maps.event.addListener poly, 'mouseover', ->
            # return if this == selectedPolygon
            @setOptions
              fillColor:   hoverFillColor
              fillOpacity: hoverFillOpacity

          google.maps.event.addListener poly, 'mouseout', ->
            # return if this == selectedPolygon
            @setOptions
              fillColor:   fillColor
              fillOpacity: fillOpacity

          @polygons.push poly
          poly.setMap @map

        @map.fitBounds bounds

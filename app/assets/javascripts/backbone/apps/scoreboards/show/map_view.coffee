@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.MapView extends Marionette.ItemView
    template: 'scoreboards/show/_map'
    id: 'map'

    initialize: (options = {}) ->
      @polygons = []

      si = App.request 'entities:scoreboardInfo'
      @precinctResults = si.get 'precinctResults'
      @precinctResults.on 'sync', @updateColors, @

      @precincts = App.request 'entities:precincts'
      if options.infoWindow
        @infoWindow = new google.maps.InfoWindow()
        self = @
        google.maps.event.addListener @infoWindow, 'domready', ->
          $('.iw-all a').on 'click', (e) ->
            e.preventDefault()

            self.infoWindow.close()

            precinct = self.focusedPrecinct
            self.focusedPrecinct = null

            App.vent.trigger 'region:selected', precinct

            if options.infoWindow != 'simple'
              App.navigate 'list', trigger: true

    updateColors: ->
      @infoWindow?.close()

      items     = @precinctResults.get 'items'
      precincts = @precinctResults.get 'precincts'

      for p in @polygons
        res = precincts.get p.data.precinctId
        p.data.colors = @precinctColors items, res
        p.data.precinctResult = res

        p.setOptions
          fillColor:   p.data.colors.fillColor
          fillOpacity: p.data.colors.fillOpacity
          strokeColor: p.data.colors.strokeColor
          strokeWeight: p.data.colors.strokeWeight
          zIndex:       p.data.colors.zIndex

    onShow: ->
      @initMap()
      @renderPrecincts()

    onClose: ->
      @removePreviousPolygons()
      @precinctResults.off 'sync', @updateColors, @
      delete @map
      delete @polygons
      delete @precinctResults
      delete @precincts
      delete @infoWindow if @infoWindow?

    initMap: ->
      center = new google.maps.LatLng gon.mapCenterLat, gon.mapCenterLon
      mapOptions =
        center:                 center
        zoom:                   gon.mapZoom
        mapTypeId:              google.maps.MapTypeId.ROADMAP

      if @options.hideControls
        mapOptions.disableDefaultUI = true
      else
        mapOptions.mapTypeControl = true
        mapOptions.mapTypeControlOptions =
          style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
        mapOptions.navigationControl = true

      if @options.noZoom
        mapOptions.disableDoubleClickZoom = true
        mapOptions.scrollwheel = false
      if @options.noPanning
        mapOptions.draggable = false

      @map = new google.maps.Map @el, mapOptions

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

      if @options.whiteBackground
        style.push {
          featureType: 'labels'
          stylers: [ lightness: 100 ]
        }

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

    removePreviousPolygons: ->
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
      fillColor     = '#ffffff'
      fillOpacity   = 0.4
      hoverColor    = fillColor
      hoverOpacity  = 0.4
      strokeColor   = '#ffffff'
      strokeWeight  = 0.7
      zIndex        = 1

      if precinctResult?
        # Highlight with opacity if precinct is in range
        hoverOpacity = 0.9
        fillOpacity  = 0.7
        if precinctResult.get('inRegion')
          strokeColor  = '#000000'
          strokeWeight = 1
          zIndex       = 2

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
        strokeColor:      strokeColor
        strokeWeight:     strokeWeight
        zIndex:           zIndex
      }

    onPolygonMouseOver: ->
      @setOptions
        fillColor:   @.data.colors.hoverFillColor
        fillOpacity: @.data.colors.hoverFillOpacity

    onPolygonMouseOut: ->
      @setOptions
        fillColor:   @.data.colors.fillColor
        fillOpacity: @.data.colors.fillOpacity

    fullInfoWindowHtml: (poly, precinct) ->
      si = App.request 'entities:scoreboardInfo'
      results = si.get 'precinctResults'
      result = si.get 'result'
      title = result.get('summary').get('title')

      precinctResult = poly.data.precinctResult
      rows  = precinctResult.get('rows')
      votes = precinctResult.get('votes')

      rowsHtml = ""
      items = results.get('items')

      totalDisplayed = 0
      for row in rows.models
        i = items.get row.get('id')
        v = row.get('votes') || 0
        totalDisplayed += v
        p = Math.floor((v * 1000) / (votes || 1)) / 10.0
        rowsHtml += "<tr><td class='iw-n'>#{i.get('name')}</td><td class='iw-v'>#{v}</td><td class='iw-p'>#{p}%</td></tr>"

      if votes > totalDisplayed
        v = votes - totalDisplayed
        p = Math.floor((v * 1000) / (votes || 1)) / 10.0
        rowsHtml += "<tr><td class='iw-n'>Others</td><td class='iw-v'>#{v}</td><td class='iw-p'>#{p}%</td></tr>"

      "<div class='precinct-bubble'><h5>#{precinct.get('name')}</h5><p>#{title}</p><table class='iw-rows'>#{rowsHtml}</table><div class='iw-all'><a>View All Races</a></div></div>"

    simpleInfoWindowHtml: (poly, precinct) ->
      "<div class='precinct-bubble'><h5>#{precinct.get('name')}</h5><div class='iw-all'><a href='#'>Set as Region</a></div></div>"

    onPolygonClick: (e) ->
      return if !@.data.precinctResult?

      @setOptions
        fillColor:   @.data.colors.hoverFillColor
        fillOpacity: @.data.colors.hoverFillOpacity

      mapView = @.data.mapView

      pid = @.data.precinctId
      precincts = App.request 'entities:precincts'
      precinct = precincts.get pid
      mapView.focusedPrecinct = precinct
      
      if mapView.options.infoWindow == 'simple'
        html = mapView.simpleInfoWindowHtml @, precinct
      else
        html = mapView.fullInfoWindowHtml @, precinct

      infoWindow = mapView.infoWindow
      infoWindow.setContent html
      infoWindow.setPosition e.latLng
      infoWindow.open(mapView.map)

    renderPrecincts: ->
      App.execute 'when:fetched', @precincts, =>
        @removePreviousPolygons()

        bounds  = new google.maps.LatLngBounds()
        results = @precinctResults.get 'precincts'
        items   = @precinctResults.get 'items'

        for precinct in @precincts.models
          precinctId = precinct.get 'id'
          res = results.get precinctId
          kml = precinct.get 'kml'
          colors = @precinctColors items, res

          lines = @pointsFromKml(kml)

          for points in lines
            bounds.extend(point) for point in points

          poly = new google.maps.Polygon
            paths:          lines,
            strokeColor:    colors.strokeColor
            strokeOpacity:  1
            strokeWeight:   colors.strokeWeight
            fillColor:      colors.fillColor
            fillOpacity:    colors.fillOpacity
            zIndex:         colors.zIndex
            data:
              precinctId:       precinctId
              colors:           colors
              precinctResult:   res
              mapView:          @

          if @options.infoWindow
            google.maps.event.addListener poly, 'mouseover', @onPolygonMouseOver
            google.maps.event.addListener poly, 'mouseout', @onPolygonMouseOut
            google.maps.event.addListener poly, 'click', @onPolygonClick

          @polygons.push poly
          poly.setMap @map

        @map.fitBounds bounds

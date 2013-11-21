map          = null
bounds       = null
statesPoints = null
countyPoints = null

window.onCountyPolygon = (data) ->
  countyPoints = pointsFromData(data, true)
  highlightCounty()

window.onStatesPolygon = (data) ->
  statesPoints = pointsFromData(data, false)
  highlightCounty()

highlightCounty = ->
  return if !statesPoints or !countyPoints
  poly = new google.maps.Polygon
    paths:          [ statesPoints, countyPoints ]
    strokeColor:    '#000000'
    strokeOpacity:  0.3
    strokeWeight:   1
    fillColor:      '#FFFFFF'
    fillOpacity:    0.5

  poly.setMap(map)
  # map.fitBounds(bounds)

pointsFromData = (data, extendBounds) ->
  if data.error
    alert(data.error.message)
    return

  row = data['rows'][0]
  pointsFromDataRow(row, extendBounds)

pointsFromDataRow = (row, extendBounds) ->
  geos = row[0]['geometries']
  if geos
    list = []
    for geo in geos
      list.push(pointsFromGeo(geo, extendBounds))
    return list
  else
    geo = row[0]['geometry']
    return pointsFromGeo(geo, extendBounds)

pointsFromGeo = (geo, extendBounds) ->
  newCoordinates = []
  coordinates = geo['coordinates'][0]

  # try adding points in the reverse direction for extendBounds=true
  for i in coordinates
    pnt = new google.maps.LatLng(i[1], i[0])
    if extendBounds
      newCoordinates.unshift(pnt)
    else
      newCoordinates.push(pnt)

    bounds.extend(pnt) if extendBounds
  newCoordinates

loadGeometryPolygon = (mapId, where, apiKey, callbackName) ->
  script = document.createElement('script')
  url = [ 'https://www.googleapis.com/fusiontables/v1/query?' ]
  url.push('sql=')

  query = "SELECT geometry FROM #{mapId} WHERE #{where}"
  encodedQuery = encodeURIComponent(query)

  url.push(encodedQuery)
  url.push("&callback=#{callbackName}")
  url.push("&key=#{apiKey}")

  script.src = url.join('')
  body = document.getElementsByTagName('body')[0]
  body.appendChild(script)

selectedPolygon = null
infoWindow = new google.maps.InfoWindow()

deselectPolygon = ->
  return unless selectedPolygon
  selectedPolygon.setOptions
    fillColor:   selectedPolygon.data.fillColor
    fillOpacity: selectedPolygon.data.fillOpacity
  selectedPolygon = null

google.maps.event.addListener infoWindow, 'closeclick', ->
  deselectPolygon()

window.onResults = (data) ->
  rows = data['rows']
  for row in rows
    ((row) ->
      points = pointsFromDataRow(row, false)
      party = row[2]
      if typeof(mapPartyColors) == 'undefined'
        fillColor        = '#000000'
        fillOpacity      = 0.3
        hoverFillColor   = fillColor
        hoverFillOpacity = 0.5
        clickFillColor   = '#cccc00'
        clickFillOpacity = 0.8
      else
        fillColor        = mapPartyColors[party] || mapPartyColors['default']
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
        return if this == selectedPolygon
        @setOptions
          fillColor:   hoverFillColor
          fillOpacity: hoverFillOpacity

      google.maps.event.addListener poly, 'mouseout', ->
        return if this == selectedPolygon
        @setOptions
          fillColor:   fillColor
          fillOpacity: fillOpacity

      google.maps.event.addListener poly, 'click', (e) ->
        deselectPolygon()

        @setOptions
          fillColor:   clickFillColor
          fillOpacity: clickFillOpacity
        selectedPolygon = this

        infoWindow.setContent row[1]
        infoWindow.setPosition e.latLng
        infoWindow.open(map)


      poly.setMap(map)
    )(row)

loadResults = (mapId, apiKey) ->
  script = document.createElement('script')
  url = [ 'https://www.googleapis.com/fusiontables/v1/query?' ]
  url.push('sql=')

  query = "SELECT geometry, Popup, LeadingParty FROM #{mapId}"
  encodedQuery = encodeURIComponent(query)

  url.push(encodedQuery)
  url.push("&callback=onResults")
  url.push("&key=#{apiKey}")

  script.src = url.join('')
  body = document.getElementsByTagName('body')[0]
  body.appendChild(script)


styleMap = (map) ->
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
    map:  map
    name: 'Styled Map'

  map.mapTypes.set 'map-style', styledMapType
  map.setMapTypeId 'map-style'

initialize = ->
  center        = new google.maps.LatLng(parseFloat($("#map_center_lat").val()), parseFloat($("#map_center_lng").val()))
  stylesTableId = '1uojjAKhRXV0FEJxj6LMchuG4Y-nTHm1SzaTM9Bw'
  helperTableId = '1-hNWH5CVdzVcDDO7w5WVCO5-yc1_uG4gMOd1Uw4'
  countiesMapId = '0IMZAFCwR-t7jZnVzaW9udGFibGVzOjIxMDIxNw'
  apiKey        = $("#map_browser_key").val()
  resultsMapId  = $("#map_id").val()

  map = new google.maps.Map(document.getElementById('map'), {
    center:     center,
    zoom:       parseInt($("#map_zoom").val()),
    mapTypeControl: true,
    mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
    navigationControl: true,
    mapTypeId:  google.maps.MapTypeId.ROADMAP
  })

  styleMap(map)
  loadResults(resultsMapId, apiKey)

  bounds = new google.maps.LatLngBounds()
  # loadGeometryPolygon helperTableId, "Key = 'USA'", apiKey, 'onStatesPolygon'
  # loadGeometryPolygon countiesMapId, "'State Abbr.' = 'MN' AND 'County Name' = 'Ramsey'", apiKey, 'onCountyPolygon'


  # layer = new google.maps.FusionTablesLayer({
  #   query:
  #     select: 'geometry'
  #     from:   resultsMapId
  #   map: map
  #   styles: [
  #     polygonOptions:
  #       strokeColor: '#FFFFFF'
  #       strokeOpacity: 0.3
  #       strokeWidth: 0.5
  #       fillColor: '#FFFFFF'
  #       fillOpacity: 0.01
  #   ]
  # })

  # google.maps.event.addListener layer, 'click', (e) ->
    # layer.set "styles", [{
    #   polygonOptions:
    #     strokeColor: '#FFFFFF',
    #     strokeOpacity: 0.2,
    #     fillColor: '#000000',
    #     fillOpacity: 0.2
    # }, {
    #   where: "VTD = '" + e.row['VTD'].value + "'",
    #   polygonOptions:
    #     fillColor: '#00FF00'
    # }]

    # e.infoWindowHtml = e.row['Popup'].value

$ ->
  return if $("#pages_state").length == 0
  initialize()

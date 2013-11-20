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
  geo = row[0]['geometry']
  pointsFromGeo(geo, extendBounds)

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


initialize = ->
  center        = new google.maps.LatLng(parseFloat($("#map_center_lat").val()), parseFloat($("#map_center_lng").val()))
  helperTableId = '1-hNWH5CVdzVcDDO7w5WVCO5-yc1_uG4gMOd1Uw4'
  countiesMapId = '0IMZAFCwR-t7jZnVzaW9udGFibGVzOjIxMDIxNw'
  apiKey        = $("#map_browser_key").val()

  map = new google.maps.Map(document.getElementById('map'), {
    center:     center,
    zoom:       parseInt($("#map_zoom").val()),
    mapTypeControl: true,
    mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
    navigationControl: true,
    mapTypeId:  google.maps.MapTypeId.SATELLITE
  })

  bounds = new google.maps.LatLngBounds()
  loadGeometryPolygon helperTableId, "Key = 'USA'", apiKey, 'onStatesPolygon'
  loadGeometryPolygon countiesMapId, "'State Abbr.' = 'MN' AND 'County Name' = 'Ramsey'", apiKey, 'onCountyPolygon'


  layer = new google.maps.FusionTablesLayer({
    query:
      select: 'geometry',
      from:   $("#map_id").val()
    map: map
    styles: [
      polygonOptions:
        strokeColor: '#FFFFFF'
        strokeOpacity: 0.3
        strokeWidth: 0.5
        fillColor: '#FFFFFF'
        fillOpacity: 0.01
    ]
  })

  google.maps.event.addListener layer, 'click', (e) ->
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

    e.infoWindowHtml = e.row['Popup'].value

$ ->
  return if $("#pages_state").length == 0
  initialize()

initialize = ->
  center = new google.maps.LatLng(parseFloat($("#map_center_lat").val()), parseFloat($("#map_center_lng").val()))

  map = new google.maps.Map(document.getElementById('map'), {
    center:     center,
    zoom:       parseInt($("#map_zoom").val()),
    mapTypeId:  google.maps.MapTypeId.ROADMAP
  })

  layer = new google.maps.FusionTablesLayer({
    query:
      select: 'geometry',
      from:   $("#map_id").val()
    map: map
    styles: [
      polygonOptions:
        strokeColor: '#FFFFFF',
        strokeOpacity: 0.2,
        fillColor: '#000000',
        fillOpacity: 0.2
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

@ENRS.module "ResultsApp.Summary", (Summary, App, Backbone, Marionette, $, _) ->
  class Summary.Map extends Marionette.ItemView
    template: "results/summary/templates/_map"

    ui:
      map: "#map"

    onShow: ->
      center = [ -93.147, 45.005988 ]
      zoom   = 11

      center = new google.maps.LatLng(center[1], center[0])

      @map = new google.maps.Map this.ui.map[0],
        center: center
        zoom: zoom
        mapTypeControl: true
        mapTypeControlOptions:
          style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
        navigationControl: true
        mapTypeId: google.maps.MapTypeId.ROADMAP
      

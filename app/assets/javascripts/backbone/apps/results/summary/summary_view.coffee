@ENRS.module "ResultsApp.Summary", (Summary, App, Backbone, Marionette, $, _) ->
  class Summary.Sidebar extends Marionette.ItemView
    template: "results/summary/templates/_sidebar"

  class Summary.Results extends Marionette.ItemView
    template: "results/summary/templates/_results"

  class Summary.Layout extends Marionette.Layout
    template: "results/summary/templates/layout"

    regions:
      sidebarRegion: '#sidebar-region'
      resultsRegion: '#results-region'
      mapRegion:     '#map-region'

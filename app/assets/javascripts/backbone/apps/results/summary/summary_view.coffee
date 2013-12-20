@App.module "ResultsApp.Summary", (Summary, App, Backbone, Marionette, $, _) ->
  class Summary.Results extends Marionette.ItemView
    template: "results/summary/templates/_results"
    tagName: "section"
    className: "results"

  class Summary.Header extends Marionette.ItemView
    template: "results/summary/templates/_header"

  class Summary.Layout extends Marionette.Layout
    template: "results/summary/templates/layout"

    regions:
      headerRegion:  '#header-region'
      sidebarRegion: '#sidebar-region'
      resultsRegion: '#results-region'
      mapRegion:     '#map-region'

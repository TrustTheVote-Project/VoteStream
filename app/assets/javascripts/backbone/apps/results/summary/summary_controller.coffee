@ENRS.module "ResultsApp.Summary", (Summary, App, Backbone, Marionette, $, _) ->

  Summary.Controller =
    showSummary: ->
      console.log 'showSummary'
      layout = new Summary.Layout

      layout.on "show", =>
        layout.sidebarRegion.show new Summary.Sidebar
        layout.resultsRegion.show new Summary.Results
        layout.mapRegion.show new Summary.Map

      App.mainRegion.show layout

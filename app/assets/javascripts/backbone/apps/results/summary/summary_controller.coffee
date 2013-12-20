@App.module "ResultsApp.Summary", (Summary, App, Backbone, Marionette, $, _) ->

  Summary.Controller =
    showSummary: ->
      console.log 'showSummary'
      layout = new Summary.Layout

      layout.on "show", =>
        layout.headerRegion.show  new Summary.Header
        layout.sidebarRegion.show new Summary.Sidebar.View
        layout.resultsRegion.show new Summary.Results
        layout.mapRegion.show new Summary.Map

      App.mainRegion.show layout

@App.module "ResultsApp", (ResultsApp, App, Backbone, Marionette, $, _) ->

  API =
    showSummary: ->
      ResultsApp.Summary.Controller.showSummary()

  ResultsApp.on "start", ->
    API.showSummary()

@App.module "HeaderApp", (HeaderApp, App, Backbone, Marionette, $, _) ->

  HeaderApp.Controller =
    show: ->
      view = new HeaderApp.View
        model: App.request('entities:scoreboardInfo')

      App.headerRegion.show view

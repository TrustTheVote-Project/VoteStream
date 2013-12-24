@App.module "ScoreboardsApp.Header", (Header, App, Backbone, Marionette, $, _) ->

  Header.Controller =
    show: ->
      console.log 'header.show'

      view = new Header.View
        model: App.request('entities:scoreboardInfo')

      App.headerRegion.show view
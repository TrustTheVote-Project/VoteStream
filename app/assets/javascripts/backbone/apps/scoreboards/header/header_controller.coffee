@App.module "ScoreboardsApp.Header", (Header, App, Backbone, Marionette, $, _) ->

  Header.Controller =
    show: ->
      view = new Header.View
        model: App.request('entities:scoreboardInfo')

      App.vent.on 'region:selected category:selected view:selected', ->
        view.closePopovers()

      App.headerRegion.show view

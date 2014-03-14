@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller =
    show: ->
      view = new Show.View
      App.mainRegion.show view

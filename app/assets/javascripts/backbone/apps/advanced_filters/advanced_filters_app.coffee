@App.module "AdvancedFiltersApp", (AdvancedFiltersApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  class AdvancedFiltersApp.Router extends Marionette.AppRouter
    initialize: ->
      App.vent.on 'advancedFilterChange', @updateUrl
      
    updateUrl: ->
      af = App.request 'entities:advancedFilter'
      params = af.requestData()
      App.navigate "advanced-filters/#{$.param(params)}"
      
    appRoutes:
      "advanced-filters(/:params)": "show"

  API =
    show: (params) ->
      AdvancedFiltersApp.Show.Controller.show()
      if params
        App.execute 'when:fetched', App.request('entities:precincts'),  =>
          af = App.request('entities:advancedFilter')
          af.fromParams(params)
          #App.vent.trigger 'advancedFilterChange'

  App.addInitializer ->
    new AdvancedFiltersApp.Router
      controller: API

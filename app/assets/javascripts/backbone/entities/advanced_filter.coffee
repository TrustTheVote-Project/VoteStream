@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.AdvancedFilter extends Backbone.Model

  API =
    getAdvancedFilter: ->
      unless Entities.advancedFilter?
        Entities.advancedFilter = new Entities.AdvancedFilter
          selectedContests: new Backbone.Collection
          selectedDistricts: new Backbone.Collection
          selectedPrecincts: new Backbone.Collection

      Entities.advancedFilter

  App.reqres.setHandler 'entities:advancedFilter', -> API.getAdvancedFilter()

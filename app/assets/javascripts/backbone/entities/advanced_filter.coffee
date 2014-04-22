@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.AdvancedFilter extends Backbone.Model
    requestData: ->
      sc = @get 'selectedContests'
      sd = @get 'selectedDistricts'
      sp = @get 'selectedPrecincts'

      return {
        electionUID: gon.election_uid
        cid: sc.pluck('id').join('-')
        did: sd.pluck('id').join('-')
        pid: sp.pluck('id').join('-')
      }

  API =
    getAdvancedFilter: ->
      unless Entities.advancedFilter?
        Entities.advancedFilter = new Entities.AdvancedFilter
          selectedContests: new Backbone.Collection
          selectedDistricts: new Backbone.Collection
          selectedPrecincts: new Backbone.Collection

      Entities.advancedFilter

  App.reqres.setHandler 'entities:advancedFilter', -> API.getAdvancedFilter()

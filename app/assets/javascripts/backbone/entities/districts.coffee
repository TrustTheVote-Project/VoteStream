@ENRS.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.District extends Backbone.Model
  class Entities.Districts extends Backbone.Collection
    model: Entities.District

  class Entities.DistrictsSection extends Backbone.Model
    initialize: ->
      @set('districts', new Entities.Districts(@get('districts')))
  class Entities.DistrictsSections extends Backbone.Collection
    model: Entities.DistrictsSection

  API =
    getDistricts: ->
      unless Entities.districts?
        # TODO: Change this to the real data fetching...

        Entities.districts = new Entities.DistrictsSections [
          { id: 1, section: 'Federal Districts', districts: [
            { id: 1, name: 'District A' },
            { id: 2, name: 'District B' } ] }
          { id: 2, section: 'State Districts', districts: [
            { id: 3, name: 'District A' },
            { id: 4, name: 'District B' } ] }
          { id: 3, section: 'County Districts', districts: [
            { id: 5, name: 'District A' },
            { id: 6, name: 'District B' } ] }
          { id: 4, section: 'Local Districts', districts: [
            { id: 7, name: 'District A' },
            { id: 8, name: 'District B' } ] }
        ]
      Entities.districts
      
  App.reqres.setHandler 'entities:districts', -> API.getDistricts()

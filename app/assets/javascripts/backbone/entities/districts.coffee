@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.District extends Backbone.Model
  class Entities.Districts extends Backbone.Collection
    model: Entities.District
    fetchForLocality: (localityId) ->
      @fetch
        type: 'POST'
        url: '/data/districts'
        reset: true
        data:
          locality_id: localityId

  class GroupedDistricts extends Backbone.Model
    initialize: ->
      @set 'federal', new Backbone.Collection
      @set 'state',   new Backbone.Collection
      @set 'local',   new Backbone.Collection
      @set 'other',   new Backbone.Collection
      

    parse: (data) ->
      @get('federal').reset data.federal
      @get('state').reset data.state
      @get('local').reset data.mcd
      @get('other').reset data.other

    fetchForLocality: (localityId) ->
      
      @fetch
        url: '/data/districts'
        reset: true
        data:
          locality_id: localityId
          grouped: 1

  class Entities.DistrictsSection extends Backbone.Model
    initialize: ->
      @set('districts', new Entities.Districts(@get('districts')))

  class Entities.DistrictsSections extends Backbone.Collection
    model: Entities.DistrictsSection

  API =
    getDistricts: ->
      unless Entities.districts?
        scoreboardInfo = App.request "entities:scoreboardInfo"

        Entities.districts = new Entities.Districts
        Entities.districts.fetchForLocality(scoreboardInfo.get('localityId'))

      Entities.districts

    getGroupedDistricts: ->
      unless Entities.groupedDistricts?
        scoreboardInfo = App.request "entities:scoreboardInfo"

        Entities.groupedDistricts = new GroupedDistricts
        Entities.groupedDistricts.fetchForLocality(scoreboardInfo.get('localityId'))

      Entities.groupedDistricts

  App.reqres.setHandler 'entities:districts',         -> API.getDistricts()
  App.reqres.setHandler 'entities:districts:federal', -> API.getGroupedDistricts().get('federal')
  App.reqres.setHandler 'entities:districts:state',   -> API.getGroupedDistricts().get('state')
  App.reqres.setHandler 'entities:districts:local',   -> API.getGroupedDistricts().get('local')
  App.reqres.setHandler 'entities:districts:other',   -> API.getGroupedDistricts().get('other')

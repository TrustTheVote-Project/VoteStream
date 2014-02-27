@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Refcon extends Backbone.Model
  class Refcons extends Backbone.Collection
    model: Refcon

  class Entities.RefconCollection extends Backbone.Model
    initialize: ->
      @set 'federal', new Refcons
      @set 'state',   new Refcons
      @set 'local',   new Refcons
      @set 'other',   new Refcons

    parse: (data) ->
      @get('federal').reset data.federal
      @get('state').reset data.state
      @get('local').reset data.mcd
      @get('other').reset data.other

    fetchForLocality: (localityId) ->
      @fetch
        url: '/data/all_refcons'
        reset: true
        data:
          locality_id: localityId

  API =
    getRefcons: ->
      unless Entities.refcons?
        si = App.request "entities:scoreboardInfo"
        Entities.refcons = new Entities.RefconCollection
        Entities.refcons.fetchForLocality si.get('localityId')

      Entities.refcons

  App.reqres.setHandler 'entities:refcons:federal', -> API.getRefcons().get('federal')
  App.reqres.setHandler 'entities:refcons:state', -> API.getRefcons().get('state')
  App.reqres.setHandler 'entities:refcons:local', -> API.getRefcons().get('local')
  App.reqres.setHandler 'entities:refcons:other', -> API.getRefcons().get('other')

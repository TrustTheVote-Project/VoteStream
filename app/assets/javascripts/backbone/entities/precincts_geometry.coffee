@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.PrecinctGeo extends Backbone.Model
  class Entities.PrecinctGeos extends Backbone.Collection
    model: Entities.PrecinctGeo
    fetchForLocality: (locality_id) ->
      @fetch
        reset: true
        url: '/data/precincts_geometries'
        data:
          locality_id: locality_id

  API =
    getPrecinctsGeometries: ->
      unless Entities.precinctsGeometries?
        scoreboardInfo = App.request "entities:scoreboardInfo"

        Entities.precinctsGeometries = pg = new Entities.PrecinctGeos
        pg.fetchForLocality scoreboardInfo.get('localityId')

      Entities.precinctsGeometries


  App.reqres.setHandler 'entities:precinctsGeometries', -> API.getPrecinctsGeometries()

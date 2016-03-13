@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Precinct extends Backbone.Model
  class Entities.Precincts extends Backbone.Collection
    model: Entities.Precinct
    fetchForLocality: (localityId) ->
      @fetch
        type: 'POST'
        url: '/data/precincts'
        data:
          locality_id: localityId

  class Entities.PrecinctsSection extends Backbone.Model
    initialize: ->
      @set('precincts', new Entities.Precincts(@get('precincts')))
  class Entities.PrecinctsSections extends Backbone.Collection
    model: Entities.PrecinctsSection

  API =
    getPrecincts: ->
      unless Entities.precincts?
        scoreboardInfo = App.request "entities:scoreboardInfo"
        Entities.precincts = new Entities.Precincts
        Entities.precincts.fetchForLocality(scoreboardInfo.get('localityId'))
      Entities.precincts

  App.reqres.setHandler 'entities:precincts', -> API.getPrecincts()

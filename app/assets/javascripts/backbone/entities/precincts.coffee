@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Precinct extends Backbone.Model
  class Entities.Precincts extends Backbone.Collection
    model: Entities.Precinct
    url: -> "/data/localities/#{App.localityId}/precincts"

  class Entities.PrecinctsSection extends Backbone.Model
    initialize: ->
      @set('precincts', new Entities.Precincts(@get('precincts')))

  class Entities.PrecinctsSections extends Backbone.Collection
    model: Entities.PrecinctsSection


  App.reqres.setHandler 'entities:precincts', -> 
    unless Entities.precincts?
      Entities.precincts = new Entities.Precincts
      Entities.precincts.fetch()
    Entities.precincts

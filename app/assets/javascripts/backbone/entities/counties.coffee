@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.County extends Backbone.Model
  class Entities.Counties extends Backbone.Collection
    model: Entities.County
    url: -> "/data/localities/#{App.localityId}/counties"

  App.reqres.setHandler 'entities:counties', -> 
    unless Entities.counties?
      Entities.counties = new Entities.Counties
      Entities.counties.fetch()
    Entities.counties

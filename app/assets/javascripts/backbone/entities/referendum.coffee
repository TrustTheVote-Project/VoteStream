@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Referendum extends Backbone.Model
  class Entities.Referendums extends Backbone.Collection
    model: Entities.Referendum

  API =
    getReferendums: ->
      Entities.referendums ||= new Entities.Referendums gon.referendums || []

  App.reqres.setHandler 'entities:contests:referendums', -> API.getReferendums()

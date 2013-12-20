@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Contest extends Backbone.Model
  class Entities.Contests extends Backbone.Collection
    model: Entities.Contest

  API =
    getContests: ->
      Entities.contests ||= new Entities.Contests gon.contests

  App.reqres.setHandler 'entities:contests', -> API.getContests()

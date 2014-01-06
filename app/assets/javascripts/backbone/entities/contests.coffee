@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Contest extends Backbone.Model
  class Entities.Contests extends Backbone.Collection
    model: Entities.Contest

  API =
    getFederalContests: ->
      Entities.federalContests ||= new Entities.Contests gon.contests.federal
    getStateContests: ->
      Entities.stateContests ||= new Entities.Contests gon.contests.state
    getLocalContests: ->
      Entities.localContests ||= new Entities.Contests gon.contests.local
    getOtherContests: ->
      Entities.otherContests ||= new Entities.Contests gon.contests.other

  App.reqres.setHandler 'entities:contests:federal', -> API.getFederalContests()
  App.reqres.setHandler 'entities:contests:state', -> API.getStateContests()
  App.reqres.setHandler 'entities:contests:local', -> API.getLocalContests()
  App.reqres.setHandler 'entities:contests:other', -> API.getOtherContests()

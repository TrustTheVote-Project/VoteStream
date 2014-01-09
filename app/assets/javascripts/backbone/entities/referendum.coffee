@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class BallotResponse extends Backbone.Model
  class BallotResponses extends Backbone.Collection
    model: BallotResponse

  class Entities.Referendum extends Backbone.Model
    initialize: ->
      @set 'ballot_responses', new BallotResponses @get('ballot_responses')

  class Entities.Referendums extends Backbone.Collection
    model: Entities.Referendum

  API =
    getReferendums: ->
      Entities.referendums ||= new Entities.Referendums gon.referendums || []

  App.reqres.setHandler 'entities:contests:referendums', -> API.getReferendums()

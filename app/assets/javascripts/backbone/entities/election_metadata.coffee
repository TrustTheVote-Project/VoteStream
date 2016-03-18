@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.ElectionMetadata extends Backbone.Model
    fetchForLocality: (localityId) ->
      @fetch
        type: 'POST'
        url: '/data/election_metadata'
        data:
          locality_id: localityId
      
  API =
    getElectionMetadata: ->
      unless Entities.election_metadata?
        scoreboardInfo = App.request "entities:scoreboardInfo"
        Entities.election_metadata = new Entities.ElectionMetadata
        Entities.election_metadata.fetchForLocality(scoreboardInfo.get('localityId'))
      Entities.election_metadata

  App.reqres.setHandler 'entities:electionMetadata', -> API.getElectionMetadata()

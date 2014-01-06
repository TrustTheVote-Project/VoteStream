@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.VotingResult extends Backbone.Model
  class Entities.VotingResults extends Backbone.Collection
    model: Entities.VotingResult
    fetchForLocality: (localityId) ->
      @fetch
        reset: true
        url: '/data/voting_results'
        data:
          locality_id: localityId

  API =
    getVotingResults: ->
      unless Entities.votingResults?
        scoreboardInfo = App.request "entities:scoreboardInfo"

        Entities.votingResults = new Entities.VotingResults
        Entities.votingResults.fetchForLocality scoreboardInfo.get('localityId')

      Entities.votingResults

  App.reqres.setHandler 'entities:votingResults', -> API.getVotingResults()

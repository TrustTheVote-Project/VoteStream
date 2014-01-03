@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.VotingResult extends Backbone.Model
  class Entities.VotingResults extends Backbone.Collection
    model: Entities.VotingResult
    fetchForContest: (contest, region) ->
      filter =
        contest_id: contest.get('id')
        
      filter.district_id = region.get('id') if region instanceof Entities.District
      filter.precinct_id = region.get('id') if region instanceof Entities.Precinct

      @fetch
        reset: true
        url: '/data/voting_results'
        data: filter

  API =
    reloadVotingResults: ->
      scoreboardInfo = App.request "entities:scoreboardInfo"
      Entities.votingResults.fetchForContest scoreboardInfo.get('contest'), scoreboardInfo.get('region')

    getVotingResults: ->
      unless Entities.votingResults?
        scoreboardInfo = App.request "entities:scoreboardInfo"

        Entities.votingResults = new Entities.VotingResults
        API.reloadVotingResults()

        scoreboardInfo.on 'change:contest', ->
          API.reloadVotingResults() unless scoreboardInfo.get('region')?

        scoreboardInfo.on 'change:region', ->
          API.reloadVotingResults()

      Entities.votingResults

  App.reqres.setHandler 'entities:votingResults', -> API.getVotingResults()

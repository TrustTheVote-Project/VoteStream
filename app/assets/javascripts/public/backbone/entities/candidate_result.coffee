@ENRS.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.CandidateResult extends Backbone.Model

  class Entities.CandidateResultsCollection extends Backbone.Collection
    model: Entities.CandidateResult

  cache = {}

  API =
    getResultsForCounty: (county) ->
      cache[county] || (cache[county] =
        new Entities.CandidateResultsCollection [
          { precinctId: 1, candidate: 'Obama', votes: 100 },
          { precinctId: 1, candidate: 'Romney', votes: 20 } 
        ])

  App.reqres.setHandler "candidateResult:entities:county", (county) ->
    API.getResultsForCounty(county)

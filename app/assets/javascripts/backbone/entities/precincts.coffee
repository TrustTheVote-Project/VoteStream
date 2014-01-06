@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Precinct extends Backbone.Model
  class Entities.Precincts extends Backbone.Collection
    model: Entities.Precinct
    fetchForLocality: (localityId) ->
      @fetch
        url: '/data/precincts'
        data:
          locality_id: localityId

    fetchForContest: (contest) ->
      @fetch
        url: '/data/precincts'
        data:
          contest_id: contest.get('id')

  class Entities.PrecinctsSection extends Backbone.Model
    initialize: ->
      @set('precincts', new Entities.Precincts(@get('precincts')))
  class Entities.PrecinctsSections extends Backbone.Collection
    model: Entities.PrecinctsSection

  API =
    getContestPrecincts: ->
      unless Entities.contestPrecincts?
        scoreboardInfo = App.request "entities:scoreboardInfo"

        Entities.contestPrecincts = new Entities.Precincts
        Entities.contestPrecincts.fetchForContest scoreboardInfo.get('contest')

        scoreboardInfo.on 'change:contest', ->
          Entities.contestPrecincts.fetchForContest scoreboardInfo.get('contest')

      Entities.contestPrecincts


    getPrecincts: ->
      unless Entities.precincts?
        scoreboardInfo = App.request "entities:scoreboardInfo"
        Entities.precincts = new Entities.Precincts
        Entities.precincts.fetchForLocality(scoreboardInfo.get('localityId'))
      Entities.precincts

  App.reqres.setHandler 'entities:precincts', -> API.getPrecincts()
  App.reqres.setHandler 'entities:contestPrecincts', -> API.getContestPrecincts()

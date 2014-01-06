@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.District extends Backbone.Model
  class Entities.Districts extends Backbone.Collection
    model: Entities.District
    fetchForLocality: (localityId) ->
      @fetch
        url: '/data/districts'
        reset: true
        data:
          locality_id: localityId

    fetchForContest: (contest) ->
      @fetch
        url: '/data/districts'
        reset: true
        data:
          contest_id: contest.get('id')

  class Entities.DistrictsSection extends Backbone.Model
    initialize: ->
      @set('districts', new Entities.Districts(@get('districts')))

  class Entities.DistrictsSections extends Backbone.Collection
    model: Entities.DistrictsSection

  API =
    getContestDistricts: ->
      unless Entities.contestDistricts?
        scoreboardInfo = App.request "entities:scoreboardInfo"

        Entities.contestDistricts = new Entities.Districts
        Entities.contestDistricts.fetchForContest scoreboardInfo.get('contest')

        scoreboardInfo.on 'change:contest', ->
          Entities.contestDistricts.fetchForContest scoreboardInfo.get('contest')

      Entities.contestDistricts


    getDistricts: ->
      unless Entities.districts?
        scoreboardInfo = App.request "entities:scoreboardInfo"

        Entities.districts = new Entities.Districts
        Entities.districts.fetchForLocality(scoreboardInfo.get('localityId'))

      Entities.districts

  App.reqres.setHandler 'entities:districts', -> API.getDistricts()
  App.reqres.setHandler 'entities:contestDistricts', -> API.getContestDistricts()

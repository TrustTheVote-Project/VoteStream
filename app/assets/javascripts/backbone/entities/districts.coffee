@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.District extends Backbone.Model
  class Entities.Districts extends Backbone.Collection
    model: Entities.District
    fetchForContest: (contest) ->
      Entities.contestDistricts.fetch
        url: '/data/districts'
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


    # unused in new version
    getDistricts: ->
      unless Entities.districts?
        # TODO: Change this to the real data fetching...

        Entities.districts = new Entities.DistrictsSections [
          { id: 1, section: 'Federal Districts', districts: [
            { id: 1, name: 'District A' },
            { id: 2, name: 'District B' } ] }
          { id: 2, section: 'State Districts', districts: [
            { id: 3, name: 'District A' },
            { id: 4, name: 'District B' } ] }
          { id: 3, section: 'County Districts', districts: [
            { id: 5, name: 'District A' },
            { id: 6, name: 'District B' } ] }
          { id: 4, section: 'Local Districts', districts: [
            { id: 7, name: 'District A' },
            { id: 8, name: 'District B' } ] }
        ]
      Entities.districts

  App.reqres.setHandler 'entities:districts', -> API.getDistricts()
  App.reqres.setHandler 'entities:contestDistricts', -> API.getContestDistricts()

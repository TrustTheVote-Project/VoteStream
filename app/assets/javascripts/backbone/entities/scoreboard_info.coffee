@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.ScoreboardInfo extends Backbone.Model

  API =
    getScoreboardInfo: ->
      unless Entities.scoreboardInfo?
        contests = App.request 'entities:contests'

        Entities.scoreboardInfo = new Entities.ScoreboardInfo
          localityId:       gon.locality_id
          localityName:     gon.locality_name
          localityInfo:     gon.locality_info
          electionInfo:     gon.election_info
          contest:          contests.first()
          selectedRegion:   -> "All Precincts"
          percentReporting: -> 29

      Entities.scoreboardInfo

  App.reqres.setHandler 'entities:scoreboardInfo', -> API.getScoreboardInfo()

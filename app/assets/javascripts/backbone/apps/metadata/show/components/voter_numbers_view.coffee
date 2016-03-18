@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.VoterNumbersView extends Marionette.ItemView
    template: 'metadata/show/_voter_numbers'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @total = @metaData.get('total_valid_votes')
      @electionDay = @metaData.get('election_day')
      @early =  @metaData.get('early')
      @overvotes = @metaData.get('overvotes')
      @undervotes = @metaData.get('undervotes')
      @total_voters = @total + @overvotes + @undervotes
      
    serializeData: ->
      return {
        electionDay: App.ScoreboardsApp.Helpers.numberFormatted(@electionDay)
        early: App.ScoreboardsApp.Helpers.numberFormatted(@early)
        total_voters: App.ScoreboardsApp.Helpers.numberFormatted(@total_voters)
      }

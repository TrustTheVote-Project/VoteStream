@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.AbsenteeView extends Marionette.ItemView
    template: 'metadata/show/_absentee'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @absentee = @metaData.get('absentee')
      @counted = .8 * @absentee     #FAKE
      @uncounted = .2 * @absentee   #FAKE
      
      @domestic = .68 * @absentee #FAKE
      @overseas = .09 * @absentee #FAKE
      @military = .32 * @absentee #FAKE
      
    serializeData: ->
      return {
        counted: App.ScoreboardsApp.Helpers.numberFormatted(@counted)
        uncounted: App.ScoreboardsApp.Helpers.numberFormatted(@uncounted)
        domesticPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@domestic, @absentee)
        overseasPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@overseas, @absentee)
        militaryPercentage: App.ScoreboardsApp.Helpers.percentFormatted(@military, @absentee)
      }
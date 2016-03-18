@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.ProvisionalView extends Marionette.ItemView
    template: 'metadata/show/_provisional'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @provisional_total = @metaData.get('provisional')
      @provisional_counted = 5252
      @provisional_uncounted = 823
      
    serializeData: ->
      return {
        provisional_counted: App.ScoreboardsApp.Helpers.numberFormatted(@provisional_counted)
        provisional_uncounted: App.ScoreboardsApp.Helpers.numberFormatted(@provisional_uncounted)
      }
@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.ZipCodesView extends Marionette.Layout
    template: 'metadata/show/_zip_codes'
    
    regions:
      toggleRegion: '#metadata-zip-codes-toggle'

    initialize: ->
      @metaData = App.request('entities:electionMetadata')
      @demographics = @metaData.get('demographics')
      @toggler = { selected: 'voters'}
      
    onShow: ->
      @toggleRegion.show new Show.TotalTypeTogglerView({toggler: @toggler})


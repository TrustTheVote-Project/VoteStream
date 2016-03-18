@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.TotalTypeTogglerView extends Marionette.ItemView
    template: 'metadata/show/_total_type_toggler'
    className: 'toggler'

    initialize: (options)->
      @options = options
      
    serializeData: ->
      return {
        activeButton: @options.toggler.selected
      }
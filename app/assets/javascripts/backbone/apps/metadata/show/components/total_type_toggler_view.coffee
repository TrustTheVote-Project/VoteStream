@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.TotalTypeTogglerView extends Marionette.ItemView
    template: 'metadata/show/_total_type_toggler'
    className: 'toggler'
    
    events:
      'click li': 'toggle'
      
    initialize: (options)->
      @options = options
      
    serializeData: ->
      return {
        activeButton: @options.toggler.selected
      }
      
    toggle: (e)->
      val = $(e.target).data('value')
      if val != @options.toggler.selected
        @trigger 'change:selected', val
        
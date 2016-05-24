@App.module "ScoreboardsApp.FilterBar", (FilterBar, App, Backbone, Marionette, $, _) ->
  class FilterBar.SaveAsView extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_save_as'
    #template: '#save-view-as'
    
    initialize: (options) ->
      @saved_maps = App.request "entities:savedMaps"
      @url = options.url
      @mapName = options.name
      
    templateHelpers: ->
      mapName: @mapName
      
    events:
      'click .map-commit-save-button': (e) ->
        @onSave()
        
    onShow: ->
      $('#save-map-modal').on 'shown.bs.modal', (e) ->
        $("#save-map-modal input[name='saved-map-name']").focus().select()         
      
      $('#save-map-modal').modal() 
      
      
    onSave: ->
      @mapName = $("#save-map-modal input[name='saved-map-name']").val()
      @saved_maps.add_map(@url, @mapName) 
      App.vent.trigger 'saveMapAs:saved'
      $('#save-map-modal').modal('hide')
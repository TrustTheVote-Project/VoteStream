@App.module "ScoreboardsApp.FilterBar", (FilterBar, App, Backbone, Marionette, $, _) ->
  class FilterBar.ValueToggleView extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_toggle'
    itemViewContainer: 'span'
    tagName: 'span'
    className: 'toggle-box'
    
    modelEvents:
      'change': 'render'
    
    
    initialize: (options) ->
      @scoreboardInfo = options.scoreboardInfo
      @key = options.key
      @model = new Backbone.Model
        name: options.name
    
    performToggle: (e) ->
      if e
        e.preventDefault()
      checkbox = this.$el.find('input[type=checkbox]')
      value = checkbox.prop('checked')
      checkbox.prop('checked', !value)
      this.filterToggled()
    
    onRender: ->
      this.$el.find('input[type=checkbox]').prop(
        'checked', @scoreboardInfo.get(@key))
    
    filterToggled: (e) ->
      if e
        e.stopPropagation()
      checkbox = this.$el.find('input[type=checkbox]')
      value = checkbox.prop('checked')
      App.vent.trigger 'setSbData', @key, value
  
    events:
      'click [type="checkbox"]': 'filterToggled'
      'click a': 'performToggle'
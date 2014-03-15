@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.SelectorView extends Marionette.Layout
    template: 'advanced_filters/show/_selector_view'
    className: 'selector'

    regions:
      selectionStatsRegion: '.selector-stats-region'
      optionsRegion:        '.options-region'

    initialize: (options) -> @options = options

    serializeData: ->
      data = {}
      data.title = @options.title
      data

    onShow: ->
      @selectionStatsRegion.show new SelectionStatsView()
      console.log @options
      @optionsRegion.show new OptionsView rows: @options.rows or 5, collection: @options.collection


  class SelectionStatsView extends Marionette.ItemView
    template: 'advanced_filters/show/_selector_view_selection_stats'
    tagName: 'span'

  class OptionView extends Marionette.ItemView
    template: 'advanced_filters/show/_selector_view_option'
    tagName: 'option'

    onShow: ->
      @$el.attr value: @model.get('id')

  class OptionsView extends Marionette.CollectionView
    itemView: OptionView
    tagName: 'select'

    initialize: (options) -> @options = options

    onShow: ->
      @$el.attr
        multiple: 'yes'
        size: @options.rows

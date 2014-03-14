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
      @optionsRegion.show new OptionsView({ rows: @options.rows or 5 })


  class SelectionStatsView extends Marionette.ItemView
    template: 'advanced_filters/show/_selector_view_selection_stats'
    tagName: 'span'

  class OptionView extends Marionette.ItemView
    template: 'advanced_filters/show/_selector_view_option'

  class OptionsView extends Marionette.CollectionView
    itemView: OptionView
    tagName: 'select'

    initialize: (options) -> @options = options

    onShow: ->
      @$el.attr
        multiple: 'yes'
        size: @options.rows

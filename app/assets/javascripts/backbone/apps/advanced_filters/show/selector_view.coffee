@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.SelectorView extends Marionette.Layout
    template: 'advanced_filters/show/_selector_view'
    className: 'selector'

    regions:
      selectionStatsRegion: '.selector-stats-region'
      optionsRegion:        '.options-region'

    events:
      'click .js-select-all':   'onSelectAll'
      'click .js-deselect-all': 'onDeselectAll'

    initialize: (options) -> @options = options

    serializeData: ->
      data = {}
      data.title = @options.title
      data

    onShow: ->
      @optionsView = new OptionsView collection: @options.collection, selection: @options.selection, rows: @options.rows

      @selectionStatsRegion.show new SelectionStatsView selection: @options.selection
      @optionsRegion.show @optionsView

    onSelectAll: (e) ->
      e.preventDefault()
      @options.selection?.add(m) for m in @options.collection.models
      @optionsView.render()

    onDeselectAll: (e) ->
      e.preventDefault()
      @options.selection?.remove(m) for m in @options.collection.models
      @optionsView.render()


  class SelectionStatsView extends Marionette.ItemView
    template: 'advanced_filters/show/_selector_view_selection_stats'
    tagName: 'span'

  class OptionView extends Marionette.ItemView
    template: 'advanced_filters/show/_selector_view_option'
    tagName: 'div'

    events:
      'click': (e) ->
        e.preventDefault()

        if @$el.hasClass('selected')
          @$el.removeClass('selected')
          @options.selection?.remove(@model)
        else
          @$el.addClass('selected')
          @options.selection?.add(@model)


    onShow: ->
      id = @model.get('id')
      @$el.addClass('selected') if @options.selection?.get(@model.get('id'))?

  class OptionsView extends Marionette.CollectionView
    itemView: OptionView
    tagName: 'div'
    className: 'selection'

    initialize: (options) ->
      @options = options

    itemViewOptions: -> @options

    onShow: ->
      @$el.css
        height: (@options.rows or 5) * 24

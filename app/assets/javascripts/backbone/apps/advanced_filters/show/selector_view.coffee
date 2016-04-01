@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.SelectorView extends Marionette.Layout
    template: 'advanced_filters/show/_selector_view'
    className: 'selector-view'

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
      @statsView   = new SelectionStatsView collection: @options.collection, selection: @options.selection
      @optionsView = new OptionsView collection: @options.collection, selection: @options.selection, rows: @options.rows

      @listenTo @optionsView, 'itemview:selection:changed', => @onSelectionChange()
      @selectionStatsRegion.show @statsView
      @optionsRegion.show @optionsView

    onSelectAll: (e) ->
      e.preventDefault()
      @options.selection?.add(m) for m in @options.collection.models
      @optionsView.render()
      @statsView.render()

    onDeselectAll: (e) ->
      e.preventDefault()
      @options.selection?.remove(m) for m in @options.collection.models
      @optionsView.render()
      @statsView.render()

    onSelectionChange: ->
      @statsView.render()


  class SelectionStatsView extends Marionette.ItemView
    template: 'advanced_filters/show/_selector_view_selection_stats'
    tagName:  'span'

    initialize: (options) ->
      @options = options

    serializeData: ->
      data = {}
      data.count = @options.selection.length
      data

  class OptionView extends Marionette.ItemView
    template: 'advanced_filters/show/_selector_view_option'

    events:
      'click': (e) ->
        e.preventDefault()

        if @$el.hasClass('selected')
          @$el.removeClass('selected')
          @options.selection?.remove(@model)
          @model.set('selected', false)
        else
          @$el.addClass('selected')
          @options.selection?.add(@model)
          @model.set('selected', true)

        @trigger "selection:changed"

    onShow: ->
      id = @model.get('id')
      @$el.addClass('selected') if @options.selection?.get(@model.get('id'))?

  class OptionsView extends Marionette.CollectionView
    itemView:  OptionView
    className: 'options-view'

    initialize: (options) ->
      @options = options

    itemViewOptions: -> @options

    onShow: ->
      @$el.css height: (@options.rows or 5) * 24

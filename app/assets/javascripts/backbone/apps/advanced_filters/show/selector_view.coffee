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
      @onSelectionChange()

    onDeselectAll: (e) ->
      e.preventDefault()
      @options.selection?.remove(m) for m in @options.collection.models
      @optionsView.render()
      @onSelectionChange()

    onSelectionChange: ->
      @statsView.render()
      App.vent.trigger 'advancedFilterChange'


  class SelectionStatsView extends Marionette.ItemView
    template: 'advanced_filters/show/_selector_view_selection_stats'
    tagName:  'span'

    initialize: (options) ->
      @options = options


    onShow: ->
      # console.log(@options.selection)
      
    serializeData: ->
      data = {}
      data.count = @$el.parents(".selector-view").find(".selected").length
      data

  class OptionView extends Marionette.ItemView
    template: 'advanced_filters/show/_selector_view_option'

    initialize: (options) ->
      @af = App.request 'entities:advancedFilter'
      @model.on 'setSelected', =>
        @doSelect()

    doSelect: ->
      @$el.addClass('selected')
      @trigger "selection:changed"
    
    doUnSelect: ->
      @$el.removeClass('selected')
      @trigger "selection:changed"

    events:
      'click': (e) ->
        e.preventDefault()

        if @$el.hasClass('selected')
          @af.unselect(@options.selection, @model)
          @doUnSelect();
        else
          @af.select(@options.selection, @model)
          @doSelect()

        

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

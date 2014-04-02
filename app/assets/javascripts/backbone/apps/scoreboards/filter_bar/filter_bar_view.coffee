@App.module "ScoreboardsApp.FilterBar", (FilterBar, App, Backbone, Marionette, $, _) ->

  hidePopoversExcept = (exception) ->
    $(".popover").each (i, po) ->
      $(po).hide() unless po == exception

  class FilterBar.View extends Marionette.Layout
    template: 'scoreboards/filter_bar/view'
    id: 'filter_bar'

    ui:
      popover: '.popover.precinct-status'

    events:
      'click #js-tweet': 'onTweet'
      'click #js-facebook-share': 'onFacebookShare'
      'click #js-gplus': 'onGooglePlus'

    regions:
      federalDropdownRegion:  '#federal-dropdown-region'
      stateDropdownRegion:    '#state-dropdown-region'
      localDropdownRegion:    '#local-dropdown-region'
      otherDropdownRegion:    '#other-dropdown-region'

      districtDropdownRegion: '#district-dropdown-region'
      precinctDropdownRegion: '#precinct-dropdown-region'

      breadcrumbsRegion:      '#breadcrumbs-region'
      viewSelectorRegion:     '#view-selector-region'

    closePopovers: ->
      $(".popover", @$el).hide()

    onTweet: (e) ->
      e.preventDefault()
      url = document.location.href
      text = gon.tweetText
      window.open "http://twitter.com/intent/tweet?url=#{encodeURIComponent(url)}&text=#{encodeURIComponent(text)}"

    onFacebookShare: (e) ->
      e.preventDefault()
      url = document.location.href
      window.open "https://www.facebook.com/sharer/sharer.php?u=#{encodeURIComponent(url)}"

    onGooglePlus: (e) ->
      e.preventDefault()
      url = document.location.href
      window.open "https://plus.google.com/share?url=#{encodeURIComponent(url)}"

    onShow: ->
      scoreboardInfo = App.request "entities:scoreboardInfo"

      @.federalDropdownRegion.show new SelectorView
        name: 'Federal'
        itemView: ContestSelectorRow
        prependedCollection: new Backbone.Collection([ App.request("entities:refcon:all-Federal") ])
        model: scoreboardInfo
        collection: App.request 'entities:refcons:federal'
      @.stateDropdownRegion.show new SelectorView
        name: 'State'
        itemView: ContestSelectorRow
        prependedCollection: new Backbone.Collection([ App.request("entities:refcon:all-State") ])
        model: scoreboardInfo
        collection: App.request 'entities:refcons:state'
      @.localDropdownRegion.show new SelectorView
        name: 'Local'
        itemView: ContestSelectorRow
        prependedCollection: new Backbone.Collection([ App.request("entities:refcon:all-MCD") ])
        model: scoreboardInfo
        collection: App.request 'entities:refcons:local'
      @.otherDropdownRegion.show new SelectorView
        name: 'Other'
        itemView: ContestSelectorRow
        prependedCollection: new Backbone.Collection([
          App.request("entities:refcon:all-Other"),
          App.request("entities:refcon:all-referenda")
        ])
        model: scoreboardInfo
        collection: App.request 'entities:refcons:other'

      App.execute 'when:fetched', App.request('entities:precincts'), =>
        # We give time for the map to load
        setTimeout (=>
          @.districtDropdownRegion.show new SelectorView
            name: 'Districts'
            itemView: DistrictSelectorRow
            model: scoreboardInfo
            prependedCollection: new Backbone.Collection([
              { id: null, name: gon.locality_name }
            ])

          collection: App.request 'entities:districts'
          @.precinctDropdownRegion.show new SelectorView
            name: 'Precincts'
            itemView: PrecinctSelectorRow
            model: scoreboardInfo
            prependedCollection: new Backbone.Collection([
              { id: null, name: 'All Precincts' }
            ])
            collection: App.request 'entities:precincts'
          ), 2000

      @.breadcrumbsRegion.show new BreadcrumbsView
        model: scoreboardInfo
      @.viewSelectorRegion.show new ViewSelectorView
        model: scoreboardInfo

      $("body").on "click", => @closePopovers()


  class ContestSelectorRow extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_contest_selector_row'
    tagName: 'li'
    events:
      'click': (e) ->
        e.preventDefault()
        App.vent.trigger 'refcon:selected', @model

  class SelectorView extends Marionette.CompositeView
    template: 'scoreboards/filter_bar/_selector'
    className: 'btn-group'
    itemViewContainer: 'ul'

    initialize: (options) ->
      @prependedCollection = @options.prependedCollection
      @itemView = @options.itemView

    serializeData: ->
      data = @model.toJSON()
      data.name = @options.name
      data

    _renderChildren: ->
      @startBuffering()

      @closeEmptyView()
      @closeChildren()

      if @prependedCollection and @prependedCollection.length > 0
        @prependedCollection.each (item, index) =>
          ItemView = @getItemView item
          @addItemView item, ItemView, index

      if @collection and @collection.length > 0
        @showCollection()
      else
        @showEmptyView()

      @endBuffering()


  class DistrictSelectorRow extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_district_selector_row'
    tagName: 'li'
    events:
      'click a': (e) ->
        e.preventDefault()
        region = @model
        region = null if @model.get('id') == null
        App.vent.trigger 'region:selected', region

  class PrecinctSelectorRow extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_precinct_selector_row'
    tagName: 'li'
    events:
      'click a': (e) ->
        e.preventDefault()
        region = @model
        region = null if @model.get('id') == null
        App.vent.trigger 'region:selected', region

  class SelectedRegionView extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_selected_region'
    tagName: 'span'
    modelEvents:
      'change:region': 'render'

  class BreadcrumbsView extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_breadcrumbs'
    modelEvents:
      'change:refcon change:region': 'render'

  class ViewSelectorView extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_view_selector'

    modelEvents:
      'change:view': 'render'

    className: 'btn-group'

    events:
      'click button': (e) ->
        e.preventDefault()
        link = $(e.target)
        App.navigate link.data('view'), trigger: true

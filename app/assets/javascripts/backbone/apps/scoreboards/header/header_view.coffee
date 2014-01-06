@App.module "ScoreboardsApp.Header", (Header, App, Backbone, Marionette, $, _) ->

  class Header.View extends Marionette.Layout
    template: 'scoreboards/header/view'
    id: 'header'

    regions:
      contestSelectorRegion: '#contest-selector-region'
      regionSelectorRegion:  '#region-selector-region'

    closePopovers: ->
      @regionSelector.closePopover()

    onShow: ->
      scoreboardInfo = App.request "entities:scoreboardInfo"

      @.contestSelectorRegion.show @contestSelector = new ContestSelectorView
        model: scoreboardInfo
      @.regionSelectorRegion.show @regionSelector = new RegionSelectorView
        model: scoreboardInfo


  class ContestSelectorView extends Marionette.Layout
    template: 'scoreboards/header/_contest_selector'

    ui:
      popover: '.popover'

    regions:
      contestsRegion: '#contests-region'

    modelEvents:
      'change:contest': 'render'

    closePopover: ->
      @ui.popover.hide()

    events:
      'click .js-trigger': (e) ->
        e.preventDefault()
        $(".popover").each (i, po) =>
          $(po).hide() unless po == @ui.popover[0]
        @ui.popover.toggle()

    onShow: ->
      @.contestsRegion.show @contestsView = new ContestsView
        collection: App.request "entities:contests"

    onRender: ->
      if @contestsView
        @.contestsRegion.show @contestsView


  class ContestView extends Marionette.ItemView
    template: 'scoreboards/header/_contest'
    tagName: 'li'

    events:
      'click a': (e) ->
        e.preventDefault()
        info = App.request 'entities:scoreboardInfo'
        info.set 'contest', @model
        $(this).parents(".popover").hide()


  class ContestsView extends Marionette.CollectionView
    tagName: 'ul'
    itemView: ContestView


  class RegionSelectorView extends Marionette.Layout
    template: 'scoreboards/header/_region_selector'

    regions:
      regionLabelRegion: '#region-label-region'
      selectorRegion:    '#selector-region'

    ui:
      popover:      '.popover'
      allTab:       '.js-tab-all'
      precinctsTab: '.js-tab-precincts'
      districtsTab: '.js-tab-districts'

    closePopover: ->
      @ui.popover.hide()

    events:
      'click .js-trigger': (e) ->
        e.preventDefault()
        $(".popover").each (i, po) =>
          $(po).hide() unless po == @ui.popover[0]
        @ui.popover.toggle()
      'click .js-tab-districts': (e) ->
        e.preventDefault()
        @showDistrictsView()
      'click .js-tab-precincts': (e) ->
        e.preventDefault()
        @showPrecinctsView()
      'click .js-tab-all': (e) ->
        e.preventDefault()
        @showAllView()

    showDistrictsView: ->
      @.ui.districtsTab.addClass('active')
      @.ui.precinctsTab.removeClass('active')
      @.ui.allTab.removeClass('active')
      @.selectorRegion.show new DistrictsView
        collection: App.request 'entities:districts'

    showPrecinctsView: ->
      @.ui.precinctsTab.addClass('active')
      @.ui.districtsTab.removeClass('active')
      @.ui.allTab.removeClass('active')
      @.selectorRegion.show new PrecinctsView
        collection: App.request 'entities:precincts'

    showAllView: ->
      @.ui.allTab.addClass('active')
      @.ui.districtsTab.removeClass('active')
      @.ui.precinctsTab.removeClass('active')
      @.selectorRegion.show new AllPrecinctsView

    onShow: ->
      @showAllView()

      scoreboardInfo = App.request 'entities:scoreboardInfo'
      @.regionLabelRegion.show new SelectedRegionView
        model: scoreboardInfo

  class AllPrecinctsView extends Marionette.ItemView
    template: 'scoreboards/header/_all_precincts'
    tagName: 'ul'
    events:
      'click a': (e) ->
        e.preventDefault()
        App.vent.trigger 'region:selected', null

  class DistrictView extends Marionette.ItemView
    template: 'scoreboards/header/_district'
    tagName: 'li'
    events:
      'click a': (e) ->
        e.preventDefault()
        App.vent.trigger 'region:selected', @model

  class DistrictsView extends Marionette.CollectionView
    tagName: 'ul'
    itemView: DistrictView

    collectionEvents:
      reset: 'render'

  class PrecinctView extends Marionette.ItemView
    template: 'scoreboards/header/_precinct'
    tagName: 'li'
    events:
      'click a': (e) ->
        e.preventDefault()
        App.vent.trigger 'region:selected', @model

  class PrecinctsView extends Marionette.CollectionView
    tagName: 'ul'
    itemView: PrecinctView

  class SelectedRegionView extends Marionette.ItemView
    template: 'scoreboards/header/_selected_region'
    tagName: 'span'
    modelEvents:
      'change:region': 'render'

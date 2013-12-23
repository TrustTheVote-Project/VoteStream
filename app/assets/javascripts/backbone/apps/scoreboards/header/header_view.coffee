@App.module "ScoreboardsApp.Header", (Header, App, Backbone, Marionette, $, _) ->

  class Header.View extends Marionette.Layout
    template: 'scoreboards/header/view'
    id: 'header'

    regions:
      contestSelectorRegion: '#contest-selector-region'
      regionSelectorRegion:  '#region-selector-region'

    onShow: ->
      scoreboardInfo = App.request "entities:scoreboardInfo"

      @.contestSelectorRegion.show new ContestSelectorView
        model: scoreboardInfo
      @.regionSelectorRegion.show new RegionSelectorView
        model: scoreboardInfo


  class ContestSelectorView extends Marionette.Layout
    template: 'scoreboards/header/_contest_selector'

    ui:
      popover: '.popover'

    regions:
      contestsRegion: '#contests-region'

    modelEvents:
      change: 'render'

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
      selectorRegion: '#selector-region'

    ui:
      popover: '.popover'
      precinctsTab: '.js-tab-precincts'
      districtsTab: '.js-tab-districts'

    events:
      'click .js-trigger': (e) ->
        e.preventDefault()
        $(".popover").each (i, po) =>
          $(po).hide() unless po == @ui.popover[0]
        @ui.popover.toggle()
      'click .js-tab-districts': (e) ->
        e.preventDefault()
        @.selectorRegion.show @districtsView
        @.ui.precinctsTab.removeClass('active')
        @.ui.districtsTab.addClass('active')
      'click .js-tab-precincts': (e) ->
        e.preventDefault()
        @.selectorRegion.show @precinctsView
        @.ui.precinctsTab.addClass('active')
        @.ui.districtsTab.removeClass('active')
        

    onShow: ->
      @districtsView = new DistrictsView
        collection: App.request 'entities:contestDistricts'
      @precinctsView = new PrecinctsView
        collection: App.request 'entities:contestPrecincts'
      @.selectorRegion.show @districtsView


  class DistrictView extends Marionette.ItemView
    template: 'scoreboards/header/_district'
    tagName: 'li'

  class DistrictsView extends Marionette.CollectionView
    tagName: 'ul'
    itemView: DistrictView

    collectionEvents:
      all: 'render'

  class PrecinctView extends Marionette.ItemView
    template: 'scoreboards/header/_precinct'
    tagName: 'li'

  class PrecinctsView extends Marionette.CollectionView
    tagName: 'ul'
    itemView: PrecinctView

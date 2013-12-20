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

    regions:
      contestsRegion: '#contests-region'

    modelEvents:
      change: 'render'

    events:
      'click .js-trigger': (e) ->
        e.preventDefault()
        $(e.target).parents('.selection').find('.popover').toggle()

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

    events:
      'click .js-trigger': (e) ->
        e.preventDefault()
        $(e.target).parents('.selection').find('.popover').toggle()
      'click .js-tab-districts': (e) ->
        e.preventDefault()
        @.selectorRegion.show @districtsView
        $('.js-tab-precincts').removeClass('active')
        $('.js-tab-districts').addClass('active')
      'click .js-tab-precincts': (e) ->
        e.preventDefault()
        @.selectorRegion.show @precinctsView
        $('.js-tab-precincts').addClass('active')
        $('.js-tab-districts').removeClass('active')
        

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

  class PrecinctView extends Marionette.ItemView
    template: 'scoreboards/header/_precinct'
    tagName: 'li'

  class PrecinctsView extends Marionette.CollectionView
    tagName: 'ul'
    itemView: PrecinctView

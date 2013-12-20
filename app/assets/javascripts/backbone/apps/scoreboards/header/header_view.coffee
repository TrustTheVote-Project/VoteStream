@App.module "ScoreboardsApp.Header", (Header, App, Backbone, Marionette, $, _) ->

  class Header.View extends Marionette.Layout
    template: 'scoreboards/header/view'
    id: 'header'

    regions:
      contestSelectorRegion: '#contest-selector-region'

    onShow: ->
      @.contestSelectorRegion.show new ContestSelectorView
        model: App.request "entities:scoreboardInfo"


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

@App.module "ScoreboardsApp.FilterBar", (FilterBar, App, Backbone, Marionette, $, _) ->
  class FilterBar.BreadcrumbsView extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_breadcrumbs'
    modelEvents:
      'change:refcon change:region': 'render'
      
    initialize: ->
      af = App.request 'entities:advancedFilter'
      af.on 'changedAdvancedFilter', =>
        @render()
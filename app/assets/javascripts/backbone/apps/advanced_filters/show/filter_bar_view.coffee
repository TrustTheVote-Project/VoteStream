@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.FilterBarView extends Marionette.ItemView
    template: 'advanced_filters/show/_filter_bar'

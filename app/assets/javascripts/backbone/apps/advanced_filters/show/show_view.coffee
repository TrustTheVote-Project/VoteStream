@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.View extends Marionette.Layout
    template: 'advanced_filters/show/view'
    id: 'advanced-filters-show'

    regions:
      filterBarRegion: '#filter-bar-region'
      contestsRegion:  '#contests-region'
      locationsRegion: '#locations-region'

    onShow: ->
      @filterBarRegion.show new Show.FilterBarView()
      @contestsRegion.show new Show.ContestsSelectorView()
      @locationsRegion.show new Show.LocationsSelectorView()

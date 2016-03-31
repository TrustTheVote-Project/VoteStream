@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.FilterBarView extends Marionette.ItemView
    template: 'advanced_filters/show/_filter_bar'

    events:
      'click #js-view-feed': 'onViewFeed'
      'click #js-view-as-map': (e) -> @viewAs(e, 'map')
      'click #js-view-as-list': (e) -> @viewAs(e, 'list')
      'click #js-view-back': (e) -> App.request('entities:scoreboardUrl').setView('map')
      'click #js-view-metadata': (e) -> App.request('entities:scoreboardUrl').setView('metadata')


    initialize: ->
      @af = App.request "entities:advancedFilter"
      App.vent.on 'advancedFilterChange', @render
      @af.on 'changedAdvancedFilter', @render
      
    viewAs: (e, view) ->
      e.preventDefault()
      App.request("entities:scoreboardUrl").setView("advanced-#{view}")

    templateHelpers:
      filtersSelected: ->
        af = App.request 'entities:advancedFilter'
        return af.filtersPresent()
        
    onViewFeed: (e) ->
      e.preventDefault()
      data = {
        'electionUID': gon.election_uid
      }
      window.open "/feed-nist.xml?#{$.param(data)}"

    onRender: ->
      $('[data-toggle="tooltip"]', @$el).tooltip();
      
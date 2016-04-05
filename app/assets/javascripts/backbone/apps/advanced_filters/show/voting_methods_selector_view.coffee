@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.VotingMethodsSelectorView extends Marionette.Layout
    template: 'advanced_filters/show/_voting_methods_selector'

    regions:
      votingMethodsRegion:    '#voting-methods-selector-region'

    onShow: ->
      af = App.request 'entities:advancedFilter'
      sm = af.get 'selectedVotingMethods'
      @votingMethodsRegion.show new Show.SelectorView title: null, collection: App.request('entities:votingmethods'), selection: sm

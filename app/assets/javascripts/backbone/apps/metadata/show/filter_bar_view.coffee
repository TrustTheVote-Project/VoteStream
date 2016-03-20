@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.FilterBarView extends Marionette.ItemView
    template: 'metadata/show/_filter_bar'

    events:
      'click #js-view-back': (e) -> window.history.back()


    templateHelpers: ->
      {}
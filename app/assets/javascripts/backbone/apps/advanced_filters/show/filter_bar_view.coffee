@App.module "AdvancedFiltersApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.FilterBarView extends Marionette.ItemView
    template: 'advanced_filters/show/_filter_bar'

    events:
      'click #js-view-feed': 'onViewFeed'

    onViewFeed: (e) ->
      e.preventDefault()
      # Encode URI to properly handle whitespace and other special characters in election_uid
      url = "/resources/v1/election_feed.xml?electionUID=#{gon.election_uid}"
      window.open encodeURI(url)

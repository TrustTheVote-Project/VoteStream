@App.module "MetadataApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.View extends Marionette.Layout
    template: 'metadata/show/view'
    id: 'metadata-show'

    regions:
      filterBarRegion: '#filter-bar-region'
      totalCountedRegion:  '#metadata-total-counted'
      turnoutRegion: '#metadata-turnout'
      voterNumbersRegion: '#metadata-voter-numbers'
      absentee: '#metadata-absentee'

    events:
      'click #js-clear-maps': (e) -> @clearMaps(e)

    serializeData: ->
      data = {}
      data

    onShow: ->
      @metaData = App.request('entities:electionMetadata')
      App.execute 'when:fetched', @metaData, =>
        @filterBarRegion.show new Show.FilterBarView()
        @totalCountedRegion.show new Show.TotalCountedView()
        @turnoutRegion.show new Show.TurnoutView()
        @voterNumbersRegion.show new Show.VoterNumbersView()
        @absentee.show new Show.AbsenteeView()
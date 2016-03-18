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
      provisional: '#metadata-provisional'
      nonParticipating: '#metadata-non-participating'
      gender: '#metadata-gender'
      age: '#metadata-age'
      party: '#metadata-party'
      race: '#metadata-race'
      voterCharacteristics: '#metadata-voter-characteristics'
      zipCodes: '#metadata-zip-codes'
      
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
        @provisional.show new Show.ProvisionalView()
        @nonParticipating.show new Show.NonParticipatingView()
        @gender.show new Show.GenderView()
        @age.show new Show.AgeView()
        @party.show new Show.PartyView()
        @race.show new Show.RaceView()
        @voterCharacteristics.show new Show.VoterCharacteristicsView()
        @zipCodes.show new Show.ZipCodesView()
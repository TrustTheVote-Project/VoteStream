@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Contest or Referendum
  # - type
  # - id
  class RefCon extends Backbone.Model
  class Entities.RefCons extends Backbone.Collection
    model: RefCon
    fetchForRegion: (localityId, region) ->
      filter = locality_id: localityId
      if region?
        console.log region
        rid = region.get 'id'
        if region instanceof App.Entities.District
          filter.district_id = rid
        else
          filter.precinct_id = rid

      @fetch
        url:   '/data/refcons'
        reset: true
        data:  filter
          
  # Single results row
  # - name
  # - votes
  # - party (optional)
  class ResultRow extends Backbone.Model
  class ResultRows extends Backbone.Collection
    model: ResultRow

  # RefCon results summary for the given region
  # - voters_total
  # - votes_total
  # - rows (ResultRow collection)
  class ResultsSummary extends Backbone.Model
    initialize: ->
      @set 'rows', new ResultRows @get 'rows'

  # RefCon results for the given Region
  # - summary (ResultsSummary) for summary display
  # - precinctResults (PrecinctResults ...)
  class Entities.Results extends Backbone.Model
    initialize: ->
      @set 'summary', new ResultsSummary
      @set 'precinctResults', new PrecinctResults

    parse: (data) ->
      { summary:         new ResultsSummary data?.summary,
        precinctResults: new PrecinctResults data?.precinctResults }

    hasData: ->
      @get('summary')?

    fetchForRefCon: (refcon, region) ->
      unless refcon?
        @set 'precinctResults', null
        @set 'summary', null
        @trigger 'reset'
        return

      rcid = refcon.get('id')
      rcty = refcon.get('type')

      filter = {}
      filter.contest_id = rcid if rcty == 'contest'
      filter.referendum_id = rcid if rcty == 'referendum'
      rid = region?.get 'id'
      if region instanceof Entities.District
        filter.district_id = rid
      else if region instanceof Entities.Precinct
        dilter.precinct_id = rid

      @fetch
        url: '/data/results'
        reset: true
        data: filter

  # RefCon results summary for individual precinct
  # - pid
  # - votes_total
  # - leading_party
  # - rows (top 2) (ResultRow collection)
  class PrecinctResult extends Backbone.Model
    initialize: ->
      @set 'rows', new ResultRows @get 'rows'
  class PrecinctResults extends Backbone.Collection


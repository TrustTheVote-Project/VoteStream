@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # id - c
  class PrecinctColor extends Backbone.Model

  class Entities.PrecinctColors extends Backbone.Collection
    model: PrecinctColor

    fetchForResult: (result, region) ->
      @reset []
      @trigger 'sync'
      return if !result?

      filter = {}

      rid = result.get('id')
      if result.get('type') == 'c'
        filter.contest_id = rid
      else
        filter.referendum_id = rid

      af = App.request('entities:advancedFilter')
      advanced = af.filterParams()

      if advanced and App.request('entities:scoreboardUrl').advancedView()
        filter.district_id = advanced.district_id
        filter.precinct_id = advanced.precinct_id

      else if region?
        rid = region.get 'id'
        if region instanceof App.Entities.District
          filter.district_id = rid
        else
          filter.precinct_id = rid


      @fetch
        url:   '/data/precinct_colors'
        reset: true
        data:  filter

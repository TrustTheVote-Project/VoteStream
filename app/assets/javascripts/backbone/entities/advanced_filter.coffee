@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.AdvancedFilter extends Backbone.Model
    requestData: ->
      sc = @get 'selectedContests'
      sd = @get 'selectedDistricts'
      sp = @get 'selectedPrecincts'

      return {
        electionUID: gon.election_uid
        cid: sc.pluck('id').join('-')
        did: sd.pluck('id').join('-')
        pid: sp.pluck('id').join('-')
      }
      
    breadcrumbsContestName: ->
      sc = @get 'selectedContests'
      sc.pluck('name').join(', ')
    breadcrumbsRegionName: ->
      sd = @get 'selectedDistricts'
      sp = @get 'selectedPrecincts'
      sd.pluck('name').concat(sp.pluck('name')).join(', ')
      
    fromParams: (params) ->
      filter = {}
      sc = @get 'selectedContests'
      sp = @get 'selectedPrecincts'
      sd = @get 'selectedDistricts'
      
      # needs to use these, because these are the object inst/types that the selector views use
      fedDistricts = App.request('entities:districts:federal') 
      stateDistricts = App.request('entities:districts:state')
      localDistricts = App.request('entities:districts:local')
      otherDistricts = App.request('entities:districts:other')
      districts = App.request('entities:districts')
      precincts = App.request('entities:precincts')
      fedCons = App.request('entities:refcons:federal') 
      stateCons = App.request('entities:refcons:state')
      localCons = App.request('entities:refcons:local')
      otherCons = App.request('entities:refcons:other')
      refcons = App.request('entities:refcons')
      
      params = params.split('&')
      for param in params
        kv = param.split('=')
        filter[kv[0]] = kv[1].split('-')
        
      for cid in filter.cid
        c = fedCons.get(did) || stateCons.get(did) || localCons.get(did) || otherCons.get(did) || refcons.get(did)
        if c
          @select(sc, c)
        
      for did in filter.did
        d = fedDistricts.get(did) || stateDistricts.get(did) || localDistricts.get(did) || otherDistricts.get(did) || districts.get(did)
        if d
          @select(sd, d)
      
      for pid in filter.pid
        p = precincts.get(pid)
        if p
          @select(sp, p)
      
      @trigger('changedAdvancedFilter')
      
        
    select: (list, model) ->
      list?.add(model)
      model.set('selected', true)
      model.trigger('setSelected')
      
    unselect: (list, model) ->
      list?.remove(model)
      model.set('selected', false)
      model.trigger('setUnSelected')
      
    filterParams: ->
      sc = @get 'selectedContests'
      sd = @get 'selectedDistricts'
      sp = @get 'selectedPrecincts'
      
      #TODO are 'selected contests' just contests, or refs too?
      
      return {
        contest_id: sc.pluck('id')
        district_id: sd.pluck('id')
        precinct_id: sp.pluck('id')
      }
      
    filtersPresent: ->
      sc = @get 'selectedContests'
      sd = @get 'selectedDistricts'
      sp = @get 'selectedPrecincts'

      return sc.length > 0 || sd.length > 0 || sp.length > 0

  API =
    getAdvancedFilter: ->
      unless Entities.advancedFilter?
        Entities.advancedFilter = new Entities.AdvancedFilter
          selectedContests: new Backbone.Collection
          selectedDistricts: new Backbone.Collection
          selectedPrecincts: new Backbone.Collection

      Entities.advancedFilter

  App.reqres.setHandler 'entities:advancedFilter', -> API.getAdvancedFilter()

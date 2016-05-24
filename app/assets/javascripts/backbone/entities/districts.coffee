@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.District extends Backbone.Model
  class Entities.Districts extends Backbone.Collection
    model: Entities.District
    url: -> "/data/localities/#{App.localityId}/districts"
    federal: ->
      @where group: 'federal'
    state: ->
      @where group: 'state'
    local: ->
      @where group: 'mcd'
    other: ->
      @where group: 'other'
      
  App.reqres.setHandler 'entities:districts', -> 
    unless Entities.districts?
      Entities.districts = new Entities.Districts
      Entities.districts.fetch()
    Entities.districts

  App.reqres.setHandler 'entities:districts:federal', -> App.request("entities:districts").federal()
  App.reqres.setHandler 'entities:districts:state',   -> App.request("entities:districts").state()
  App.reqres.setHandler 'entities:districts:local',   -> App.request("entities:districts").local()
  App.reqres.setHandler 'entities:districts:other',   -> App.request("entities:districts").other()

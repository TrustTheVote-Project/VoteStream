@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Precinct extends Backbone.Model
  class Entities.Precincts extends Backbone.Collection
    model: Entities.Precinct

  class Entities.PrecinctsSection extends Backbone.Model
    initialize: ->
      @set('precincts', new Entities.Precincts(@get('precincts')))
  class Entities.PrecinctsSections extends Backbone.Collection
    model: Entities.PrecinctsSection

  API =
    getContestPrecincts: ->
      Entities.contestPrecincts = new Entities.Precincts [
        { id: 1, name: "Precinct: 1" }
        { id: 2, name: "Precinct: 2" }
      ]

    getPrecincts: ->
      unless Entities.precincts?
        # TODO: Change this to the real data fetching...

        Entities.precincts = new Entities.PrecinctsSections [
          { id: 1, section: 'Precincts A-M', precincts: [
            { id: 1, name: 'Precinct A' },
            { id: 2, name: 'Precinct B' } ] }
          { id: 2, section: 'Precincts N-S', precincts: [
            { id: 3, name: 'Precinct N' },
            { id: 4, name: 'Precinct O' },
            { id: 5, name: 'Precinct P' } ] }
          { id: 3, section: 'St. Paul', precincts: [
            { id: 6, name: 'St. Paul' } ] }
          { id: 4, section: 'Precincts T-Z', precincts: [
            { id: 7, name: 'Precinct Y' },
            { id: 8, name: 'Precinct Z' } ] }
        ]
      Entities.precincts

  App.reqres.setHandler 'entities:precincts', -> API.getPrecincts()
  App.reqres.setHandler 'entities:contestPrecincts', -> API.getContestPrecincts()

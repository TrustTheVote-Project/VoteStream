@ENRS.module "ResultsApp.Summary.Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->

  class Sidebar.View extends Marionette.Layout
    template: 'results/summary/sidebar/templates/_view'

    regions:
      districtsAccordionRegion: '#districts-accordion-region'
      precinctsAccordionRegion: '#precincts-accordion-region'

    onShow: ->
      districts = new Sidebar.DistrictsAccordion
        collection: App.request('entities:districts')

      precincts = new Sidebar.PrecinctsAccordion
        collection: App.request('entities:precincts')

      @districtsAccordionRegion.show districts
      @precinctsAccordionRegion.show precincts



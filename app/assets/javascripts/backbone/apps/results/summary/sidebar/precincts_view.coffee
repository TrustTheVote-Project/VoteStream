@ENRS.module "ResultsApp.Summary.Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->

  class Sidebar.PrecinctsItemView extends Marionette.ItemView
    template: "results/summary/sidebar/templates/_precincts_item"
    tagName: 'li'
    events:
      'click': (e) -> alert @model.get('name')


  class Sidebar.PrecinctsSectionView extends Marionette.CompositeView
    template: "results/summary/sidebar/templates/_precincts_section"
    className: 'accordion-group'
    itemView: Sidebar.PrecinctsItemView
    itemViewContainer: ".accordion-inner ul"

    initialize: ->
      @collection = @model.get('precincts')


  class Sidebar.PrecinctsAccordion extends Marionette.CollectionView
    itemView: Sidebar.PrecinctsSectionView
    className: 'accordion'
    id: 'precincts'
    
    onCollectionRendered: ->
      this.$el.collapse()

@ENRS.module "ResultsApp.Summary.Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->

  class Sidebar.DistrictsItemView extends Marionette.ItemView
    template: "results/summary/sidebar/templates/_districts_item"
    tagName: 'li'
    events:
      'click': (e) -> alert @model.get('name')


  class Sidebar.DistrictsSectionView extends Marionette.CompositeView
    template: "results/summary/sidebar/templates/_districts_section"
    className: 'accordion-group'
    itemView: Sidebar.DistrictsItemView
    itemViewContainer: ".accordion-inner ul"

    initialize: ->
      @collection = @model.get('districts')


  class Sidebar.DistrictsAccordion extends Marionette.CollectionView
    itemView: Sidebar.DistrictsSectionView
    className: 'accordion'
    id: 'districts'
    
    onCollectionRendered: ->
      this.$el.collapse()

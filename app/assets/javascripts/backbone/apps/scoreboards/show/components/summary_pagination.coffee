@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  class Show.SummaryPagination extends Marionette.ItemView
    template: 'scoreboards/show/_summary_pagination'
    className: 'row-fluid'

    initialize: ->
      @rotator = new Show.ResultsRotator

      @si = App.request 'entities:scoreboardInfo'
      @si.on 'change:result change:results', @updateView, @

    ui: ->
      prevRefCon: '#js-prev-refcon a'
      nextRefCon: '#js-next-refcon a'

    serializeData: ->
      return {
        current: @rotator.idx + 1
        total:   @rotator.results.length
      }

    events:
      'click #js-prev-refcon a': (e) ->
        e.preventDefault()
        #return if $(e.target).attr('disabled')
        @rotator.prev()

      'click #js-next-refcon a': (e) ->
        e.preventDefault()
        #return if $(e.target).attr('disabled')
        @rotator.next()

    updateView: ->
      @render()
      #if @rotator.hasPrev() then @ui.prevRefCon.removeAttr('disabled') else @ui.prevRefCon.attr('disabled', true)
      #if @rotator.hasNext() then @ui.nextRefCon.removeAttr('disabled') else @ui.nextRefCon.attr('disabled', true)

    onShow: -> @updateView()
    onClose: ->
      @rotator.onClose()
      @si.off 'change:results change:result', @updateView, @

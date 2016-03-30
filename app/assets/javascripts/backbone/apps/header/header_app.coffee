@App.module "HeaderApp", (HeaderApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  App.on 'dataready', ->
    HeaderApp.Controller.show()

@App.module "HeaderApp", (HeaderApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  HeaderApp.on "start", ->
    HeaderApp.Controller.show()

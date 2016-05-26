@App.module "ScoreboardsApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  class Show.NoRefConView extends Marionette.ItemView
    template: 'scoreboards/show/_no_refcon'

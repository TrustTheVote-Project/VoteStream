@App.module "HeaderApp", (HeaderApp, App, Backbone, Marionette, $, _) ->

  hidePopoversExcept = (exception) ->
    $(".popover").each (i, po) ->
      $(po).hide() unless po == exception

  class HeaderApp.View extends Marionette.Layout
    template: 'header/view'
    id: 'header'

    ui:
      popover: '.popover.precinct-status'

    events:
      'click #js-tweet': 'onTweet'
      'click #js-facebook-share': 'onFacebookShare'
      'click #js-gplus': 'onGooglePlus'

    onTweet: (e) ->
      e.preventDefault()
      url = document.location.href
      text = gon.tweetText
      window.open "http://twitter.com/intent/tweet?url=#{encodeURIComponent(url)}&text=#{encodeURIComponent(text)}"

    onFacebookShare: (e) ->
      e.preventDefault()
      url = document.location.href
      window.open "https://www.facebook.com/sharer/sharer.php?u=#{encodeURIComponent(url)}"

    onGooglePlus: (e) ->
      e.preventDefault()
      url = document.location.href
      window.open "https://plus.google.com/share?url=#{encodeURIComponent(url)}"


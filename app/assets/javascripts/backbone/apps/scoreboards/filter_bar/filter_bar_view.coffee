@App.module "ScoreboardsApp.FilterBar", (FilterBar, App, Backbone, Marionette, $, _) ->

  hidePopoversExcept = (exception) ->
    $(".popover").each (i, po) ->
      $(po).hide() unless po == exception

  class FilterBar.View extends Marionette.Layout
    template: 'scoreboards/filter_bar/view'
    id: 'filter_bar'

    ui:
      popover: '.popover.precinct-status'

    events:
      'click #js-tweet': 'onTweet'
      'click #js-facebook-share': 'onFacebookShare'
      'click #js-gplus': 'onGooglePlus'

    regions:
      federalDropdownRegion:  '#federal-dropdown-region'
      stateDropdownRegion:    '#state-dropdown-region'
      localDropdownRegion:    '#local-dropdown-region'
      otherDropdownRegion:    '#other-dropdown-region'

      districtDropdownRegion: '#district-dropdown-region'
      precinctDropdownRegion: '#precinct-dropdown-region'

      earlyChannelToggle: '#early-channel-toggle'
      samedayChannelToggle: '#sameday-channel-toggle'
      absenteeChannelToggle: '#absentee-channel-toggle'

      breadcrumbsRegion:      '#breadcrumbs-region'
      viewSelectorRegion:     '#view-selector-region'
      viewSettingsRegion:     '#view-settings-region'

    closePopovers: ->
      $(".popover", @$el).hide()

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

    onShow: ->
      scoreboardInfo = App.request "entities:scoreboardInfo"

      @.federalDropdownRegion.show new SelectorView
        name: 'Federal'
        itemView: ContestSelectorRow
        prependedCollection: new Backbone.Collection([ App.request("entities:refcon:all-Federal") ])
        model: scoreboardInfo
        collection: App.request 'entities:refcons:federal'
      @.stateDropdownRegion.show new SelectorView
        name: 'State'
        itemView: ContestSelectorRow
        prependedCollection: new Backbone.Collection([ App.request("entities:refcon:all-State") ])
        model: scoreboardInfo
        collection: App.request 'entities:refcons:state'
      @.localDropdownRegion.show new SelectorView
        name: 'Local'
        itemView: ContestSelectorRow
        prependedCollection: new Backbone.Collection([ App.request("entities:refcon:all-MCD") ])
        model: scoreboardInfo
        collection: App.request 'entities:refcons:local'
      @.otherDropdownRegion.show new SelectorView
        name: 'Other'
        itemView: ContestSelectorRow
        prependedCollection: new Backbone.Collection([
          App.request("entities:refcon:all-Other"),
          App.request("entities:refcon:all-referenda")
        ])
        model: scoreboardInfo
        collection: App.request 'entities:refcons:other'
      @.earlyChannelToggle.show new ValueToggleView
        name: 'Early'
        scoreboardInfo: scoreboardInfo
        key: 'channelEarly'
      @.samedayChannelToggle.show new ValueToggleView
        name: 'Same-day'
        scoreboardInfo: scoreboardInfo
        key: 'channelElectionday'
      @.absenteeChannelToggle.show new ValueToggleView
        name: 'Absentee'
        scoreboardInfo: scoreboardInfo
        key: 'channelAbsentee'

      App.execute 'when:fetched', App.request('entities:precincts'), =>
        # We give time for the map to load
        setTimeout (=>
          @.districtDropdownRegion?.show new SelectorView
            name: 'Districts'
            itemView: DistrictSelectorRow
            model: scoreboardInfo
            prependedCollection: new Backbone.Collection([
              { id: null, name: gon.locality_name }
            ])
            collection: App.request 'entities:districts'
          @.precinctDropdownRegion?.show new SelectorView
            name: 'Precincts'
            itemView: PrecinctSelectorRow
            model: scoreboardInfo
            prependedCollection: new Backbone.Collection([
              { id: null, name: 'All Precincts' }
            ])
            collection: App.request 'entities:precincts'
          ), 2000

      @.breadcrumbsRegion.show new BreadcrumbsView
        model: scoreboardInfo
      @.viewSelectorRegion.show new ViewSelectorView
        model: scoreboardInfo
      @.viewSettingsRegion.show new ViewSettingsDropdown
        model: scoreboardInfo

      $("body").on "click", => @closePopovers()


  class ContestSelectorRow extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_contest_selector_row'
    tagName: 'li'
    events:
      'click': (e) ->
        e.preventDefault()
        App.vent.trigger 'refcon:selected', @model

  class SelectorView extends Marionette.CompositeView
    template: 'scoreboards/filter_bar/_selector'
    className: 'btn-group'
    itemViewContainer: 'ul'

    initialize: (options) ->
      @prependedCollection = @options.prependedCollection
      @itemView = @options.itemView

    serializeData: ->
      data = @model.toJSON()
      data.name = @options.name
      data

    _renderChildren: ->
      @startBuffering()

      @closeEmptyView()
      @closeChildren()

      if @prependedCollection and @prependedCollection.length > 0
        @prependedCollection.each (item, index) =>
          ItemView = @getItemView item
          @addItemView item, ItemView, index

      if @collection and @collection.length > 0
        @showCollection()
      else
        @showEmptyView()

      @endBuffering()

  class ValueToggleView extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_toggle'
    itemViewContainer: 'span'
    tagName: 'span'
    className: 'toggle-box'
    
    initialize: (options) ->
      @scoreboardInfo = options.scoreboardInfo
      @key = options.key
      @model = new Backbone.Model
        name: options.name
    
    performToggle: (e) ->
      if e
        e.preventDefault()
      checkbox = this.$el.find('input[type=checkbox]')
      value = checkbox.prop('checked')
      checkbox.prop('checked', !value)
      this.filterToggled()
    
    onRender: ->
      this.$el.find('input[type=checkbox]').prop(
        'checked', @scoreboardInfo.get(@key))
    
    filterToggled: (e) ->
      if e
        e.stopPropagation()
      checkbox = this.$el.find('input[type=checkbox]')
      value = checkbox.prop('checked')
      @scoreboardInfo.set @key, value
  
    events:
      'click [type="checkbox"]': 'filterToggled'
      'click a': 'performToggle'

  class DistrictSelectorRow extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_district_selector_row'
    tagName: 'li'
    events:
      'click a': (e) ->
        e.preventDefault()
        region = @model
        region = null if @model.get('id') == null
        App.vent.trigger 'region:selected', region

  class PrecinctSelectorRow extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_precinct_selector_row'
    tagName: 'li'
    events:
      'click a': (e) ->
        e.preventDefault()
        region = @model
        region = null if @model.get('id') == null
        App.vent.trigger 'region:selected', region

  class SelectedRegionView extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_selected_region'
    tagName: 'span'
    modelEvents:
      'change:region': 'render'

  class BreadcrumbsView extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_breadcrumbs'
    modelEvents:
      'change:refcon change:region': 'render'

  class ViewSelectorView extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_view_selector'

    modelEvents:
      'change:view': 'render'

    className: 'btn-group'

    events:
      'click button': (e) ->
        e.preventDefault()
        link = $(e.target)
        App.navigate link.data('view'), trigger: true

  radiobox = (title, property, value) ->
    if value
      { settingType: 'radio', title: title, property: property, value: value, enabled: true }
    else
      { settingType: 'radio', title: title, property: property, value: value, enabled: false }

  checkbox = (title, property) ->
    { settingType: 'checkbox', title: title, property: property }

  valueCheckbox = (title, property, trueValue, falseValue) ->
    { settingType: 'checkbox', title: title, property: property, trueValue: trueValue, falseValue: falseValue }

  class ViewSettingsDropdown extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_view_settings'

    className: 'btn-group'

    initialize: () ->
      @settings_groups =
        'map': [
          radiobox('Show Results', 'coloringType', 'results')
          radiobox('Show Participation', 'coloringType', 'participation')
          radiobox('Show Party Registration', 'map_type', null)
          radiobox('Show Demographics', 'map_type', null)
        ],
        'list': [
          checkbox('Voting Method Per Contest', 'showVotingMethod')
          checkbox('Participation Per Contest', 'showParticipation')
          valueCheckbox('Percentages by Voter', 'percentageType', 'voters', 'ballots')
        ]

    events:
      'click .dropdown-menu a': (e) ->
        $anchor = $(e.currentTarget)
        if $anchor.hasClass('disabled')
          e.preventDefault()
          return false

        $input = $anchor.find('input')
        propertyName = $input.prop('name')
        inputType = $input.prop('type')

        # Use setTimeout to manually set element checked property after click event is resolved
        setTimeout(() =>
          switch inputType
            when 'checkbox'
              boolValue = !$input.prop('checked')
              $input.prop('checked', boolValue)
              newValue = if boolValue
                $input.data('true-value') ? true
              else
                $input.data('false-value') ? false
            when 'radio'
              newValue = $input.data('value')
              $input.prop('checked', true)
            else
              console.error('Unexpected checkbox type: ' + checkboxType) if console?
              return
          @model.set propertyName, newValue
        , 0)

        return false

    templateHelpers: () ->
      optionSelected: (o) ->
        unless o.property of this
          console.error("Unknown option property: " + o.property) if console?
          return false

        switch o.settingType
          when 'checkbox'
            if o.trueValue
              this[o.property] == o.trueValue
            else
              this[o.property]
          when 'radio'
            this[o.property] == o.value
          else
            console.error('Unexpected settingType: ' + o.settingType) if console?
            false

    serializeData: () ->
      data = @model.toJSON()
      if data.view of @settings_groups
        data.view_settings = @settings_groups[data.view]
      else
        console.error('Unhandled view type', data.view) if console?
      data

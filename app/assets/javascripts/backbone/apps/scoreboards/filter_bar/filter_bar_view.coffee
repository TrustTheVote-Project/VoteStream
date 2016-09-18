@App.module "ScoreboardsApp.FilterBar", (FilterBar, App, Backbone, Marionette, $, _) ->

  hidePopoversExcept = (exception) ->
    $(".popover").each (i, po) ->
      $(po).hide() unless po == exception

  class FilterBar.View extends Marionette.Layout
    template: 'scoreboards/filter_bar/view'
    templateHelpers: ->
      shouldShowFilters: ->
        return !App.request("entities:scoreboardUrl").advancedView()
        
    id: 'filter_bar'

    ui:
      popover: '.popover.precinct-status'

    events:
      'click #js-tweet': 'onTweet'
      'click #js-facebook-share': 'onFacebookShare'
      'click #js-gplus': 'onGooglePlus'
      'click #js-advanced-filters': 'viewAdvancedFilters'
      'click #js-back-to-advanced-filters': 'viewAdvancedFilters'
      'click #js-view-metadata': (e) -> App.request('entities:scoreboardUrl').setView('metadata')
      'click .map-save-button': (e) -> 
        e.preventDefault();
        @showSaveAs()
        return false;

    modelEvents:
      'change:channelEarly': 'showChannels'
      'change:channelElectionday': 'showChannels'
      'change:channelAbsentee': 'showChannels'
      'change:coloringType': ->
        @showSettings()
        @showBreadCrumbs()
      
      
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
      saveAsRegion:           '#save-view-as'

    initialize: ->
      @scoreboardInfo = App.request "entities:scoreboardInfo"
      @scoreboardUrl = App.request 'entities:scoreboardUrl'
        
    showSaveAs: ->
      url = @scoreboardUrl.path()
      @saveAsRegion.show new FilterBar.SaveAsView
        name: 'Save This Map'
        url: url

    viewAdvancedFilters: (e) ->
      e.preventDefault()
      af = App.request ('entities:advancedFilter')
      data = af.requestData()
      App.navigate "advanced-filters/#{$.param(data)}", true

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

    showChannels: ->
      @.earlyChannelToggle?.show new App.ScoreboardsApp.FilterBar.ValueToggleView
        name: 'Early'
        scoreboardInfo: @scoreboardInfo
        key: 'channelEarly'        
      @.samedayChannelToggle?.show new App.ScoreboardsApp.FilterBar.ValueToggleView
        name: 'Same-day'
        scoreboardInfo: @scoreboardInfo
        key: 'channelElectionday'
      @.absenteeChannelToggle?.show new App.ScoreboardsApp.FilterBar.ValueToggleView
        name: 'Absentee'
        scoreboardInfo: @scoreboardInfo
        key: 'channelAbsentee'


    showSettings: ->
      @.viewSettingsRegion?.show new ViewSettingsDropdown
        model: @scoreboardInfo
    showBreadCrumbs: ->
      @.breadcrumbsRegion.show new FilterBar.BreadcrumbsView
        model: @scoreboardInfo
    showViewSelector: ->
      @.viewSelectorRegion.show new ViewSelectorView
        model: @scoreboardInfo
      
      
      
    onShow: ->
      
      App.vent.on 'saveMapAs:show', @showSaveAs
      
      @.federalDropdownRegion.show new SelectorView
        name: 'Federal'
        itemView: ContestSelectorRow
        prependedCollection: new Backbone.Collection([ App.request("entities:refcon:all-Federal") ])
        model: @scoreboardInfo
        collection: App.request 'entities:refcons:federal'
      @.stateDropdownRegion.show new SelectorView
        name: 'State'
        itemView: ContestSelectorRow
        prependedCollection: new Backbone.Collection([ App.request("entities:refcon:all-State") ])
        model: @scoreboardInfo
        collection: App.request 'entities:refcons:state'
      @.localDropdownRegion.show new SelectorView
        name: 'Local'
        itemView: ContestSelectorRow
        prependedCollection: new Backbone.Collection([ App.request("entities:refcon:all-MCD") ])
        model: @scoreboardInfo
        collection: App.request 'entities:refcons:local'
      @.otherDropdownRegion.show new SelectorView
        name: 'Other'
        itemView: ContestSelectorRow
        prependedCollection: new Backbone.Collection([
          App.request("entities:refcon:all-Other"),
          App.request("entities:refcon:all-referenda")
        ])
        model: @scoreboardInfo
        collection: App.request 'entities:refcons:other'

      @showChannels()

      App.execute 'when:fetched', App.request('entities:precincts'), =>
        # We give time for the map to load
        setTimeout (=>
          @.districtDropdownRegion?.show new SelectorView
            name: 'Districts'
            itemView: DistrictSelectorRow
            model: @scoreboardInfo
            prependedCollection: new Backbone.Collection([
              { id: null, name: gon.locality_name }
            ])
            collection: App.request 'entities:districts'
          @.precinctDropdownRegion?.show new SelectorView
            name: 'Precincts'
            itemView: PrecinctSelectorRow
            model: @scoreboardInfo
            prependedCollection: new Backbone.Collection([
              { id: null, name: 'All Precincts' }
            ])
            collection: App.request 'entities:precincts'
          ), 2000

      @showBreadCrumbs()
      @showViewSelector()
      @showSettings()
      
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
    className: 'btn-group full-btn-group'
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

  

      

  
  class ViewSelectorView extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_view_selector'

    modelEvents:
      'change:view': 'render'

    className: 'btn-group'

    events:
      'click button': (e) ->
        e.preventDefault()
        link = $(e.target)
        scoreboardUrl = App.request "entities:scoreboardUrl"
        scoreboardUrl.setView(link.data('view'))
        # App.navigate link.data('view'), trigger: true

  
  
  radiobox = (title, property, value) ->
    if value
      { settingType: 'radio', title: title, property: property, value: value, enabled: true }
    else
      { settingType: 'radio', title: title, property: property, value: value, enabled: false }

  checkbox = (title, property) ->
    { settingType: 'checkbox', title: title, property: property }

  valueCheckbox = (trueTitle, falseTitle, property, trueValue, falseValue) ->
    { settingType: 'valueCheckbox', trueTitle: trueTitle, falseTitle: falseTitle, property: property, trueValue: trueValue, falseValue: falseValue }

  
      
        

  
  class ViewSettingsDropdown extends Marionette.ItemView
    template: 'scoreboards/filter_bar/_view_settings'
    className: 'btn-group'

    initialize: () ->
      @su = App.request "entities:scoreboardUrl"
      @saved_maps = App.request "entities:savedMaps"
      @settings_groups =
        'map': [
          radiobox('Show Results', 'coloringType', 'results')
          radiobox('Show Participation', 'coloringType', 'participation')
          radiobox('Show Party Registration', 'coloringType', 'partyRegistration')
          radiobox('Show Gender', 'coloringType', 'gender')
          radiobox('Show Race/Ethnicity', 'map_type', null)
          radiobox('Show Age', 'map_type', null)
          radiobox('Show Characteristics', 'map_type', null)
          radiobox('Show ZIP', 'map_type', null)
        ],
        'list': [
          checkbox('Show Vote Method', 'showVotingMethod')
          checkbox('Show Overall Participation', 'showParticipation')
          radiobox('Show Percentages by Ballots', 'percentageType', 'ballots')
          radiobox('Show Percentages by Registered Voters', 'percentageType', 'voters')
        ],
        'map-list': [
        ]
      App.vent.on 'saveMapAs:saved', =>
        @render()
        

    events:        
      'click .dropdown-menu a.change-setting': (e) ->
        $anchor = $(e.currentTarget)
        if $anchor.hasClass('disabled')
          e.preventDefault()
          return false

        $input = $anchor.find('input')
        propertyName = $input.prop('name')
        inputType = $input.prop('type')

        # Use setTimeout to manually set element checked property after click event is resolved
        switch inputType
          when 'checkbox', 'valueCheckbox'
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
        App.vent.trigger('setSbData', propertyName, newValue)
        #@model.set propertyName, newValue
        @render();          

        return false

    templateHelpers: () ->
      saved_count: @saved_maps.count()
      view: @model.get('view')
      optionSelected: (o) ->
        unless o.property of this
          console.error("Unknown option property: " + o.property) if console?
          return false

        switch o.settingType
          when 'checkbox', 'valueCheckbox'
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

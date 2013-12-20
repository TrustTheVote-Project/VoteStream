do (Marionette) ->
  _.extend Marionette.Renderer,
    root: 'backbone/apps/'

    render: (template, data) ->
      path = @getTemplate(template)
      throw "Template #{template} not found!" unless path
      path(data)

    getTemplate: (template) ->
      for path in [ template, template.split('/').insertAt(-1, 'templates').join('/') ]
        return JST[@root + path] if JST[@root + path]

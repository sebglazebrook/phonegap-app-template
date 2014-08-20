class App.Routers.AppRouter extends Backbone.Router

  initialize: ->
    @container = new App.Views.Container()
    $('body').append(@container.render().el)

  routes:
    '': 'index'

  index: ->
    @


window.App =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: ->
    @router = new App.Routers.AppRouter()
    Backbone.history.start();

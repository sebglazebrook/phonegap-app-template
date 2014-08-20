class App.Views.Container extends Backbone.View

  template: JST['container']

  tagName: "div"
  className: "container"

  render: ->
    $(@el).html(@template())
    @

  addView: (view) ->
    if (@view)
      @view.close() if @view.close
      @view.remove()
    @view = view
    $(@el).find('.content').html(@view.render().el)

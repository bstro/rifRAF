class Prlx
  # Initialize & cache private class(?) variables
  $window = $(window)
  $document = $(document)

  vendor_prefixes    =   ["-webkit-","-moz-","-ms-","-o-"]
  prefixed_elements  =   ["border-radius","transform","perspective","perspective-origin","box-shadow","background-size"]

  document_height    =   $document.height()
  window_height      =   $window.height()
  scroll_top         =   $window.scrollTop()
  scroll_bottom      =   scroll_top + @window_height

  constructor: (@el, options, fn) ->
    # Initialize & cache public instance variables
    @el_top             =   @el.offset().top
    @el_height          =   @el.height()
    @running            =   false

    # Parse options object
    for property,val of options
      args = val.match /\S+/g
      new Actor
        el: @el
        property: property
        limit: args[0]
        increment: args[1]
        trigger: args[2]

    $window.on 'resize', -> window_height = $window.height()

    # if user scrolls, cache the new scrollY value for use later and see if a frame should be rendered.
    $window.on 'scroll', (@event) =>
      scroll_top = $window.scrollTop()
      scroll_bottom = scroll_top + window_height

      # console.log @positionOfElement()

      if not @running
        requestAnimationFrame => # => @ ~ prlx instance
          while @stack?.length
            @stack.pop()()
          @running = false

      @running = true

  class Actor
    @actors ||= do => # @ ~ Actor class
      actors = []
      get: -> actors
      add: ->
        actors.push n for n in arguments
        actors
      pop: -> actors.pop()

    constructor: (@options) -> # @ ~ Actor instance
      actors = Actor.actors # alias to class object
      actors.add @

    move: -> # @ ~ Actor instance
      return => # @ ~ Actor instance
        @el.css(@property, (@el.css @property) + @increment)

  positionOfElement: ->
    (@el_top - scroll_top + @el_height) / (scroll_bottom - scroll_top + @el_height) # returns % of element on screen

  isElFullyVisible: ->
    if (scroll_bottom - @el_height) > @el_top > scroll_top
      @el.trigger 'prlx:fullyVisible'
      return true

  isElPartiallyVisible: ->
    if scroll_bottom > @el_top > (scroll_top - @el_height)
      @el.trigger 'prlx:partiallyVisible'
      return true

  positionOfPageScrolled: -> scroll_top / (document_height - window_height)

  isFunction: (obj) -> return !!(obj and obj.constructor and obj.call and obj.apply) # from _
  isObject: (obj) -> return obj is Object(obj) # from _

(($) ->
  $.fn.prlx = (options, fn) ->
    $.each this, ->
      new Prlx($(this),options)
)(jQuery)
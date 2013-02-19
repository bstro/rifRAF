class Prlx
  # Initialize & cache private instance(?) variables
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
      new Director new Actor @el, property, args[0], args[1], args[2]
  
  class Director
    @events = do => # @ should be Director class
      # if user resizes window, cache the new window height.
      $window.on 'resize', -> window_height = $window.height()

      # if user scrolls, cache the new scrollY value for use later and see if a frame should be rendered.
      $window.on 'scroll', (@event) =>
        scroll_top = $window.scrollTop()
        scroll_bottom = scroll_top + window_height

        if not @running
          requestAnimationFrame => # => @ ~ prlx instance
            while @stack?.length
              @stack.pop()()
            @running = false
        @running = true

    constructor: (@actor) ->

  # class Cue
  #   constructor: ->

  class Actor
    @actors = do => # @ ~ Actor class
      actors = []

      get: -> actors

      add: ->
        actors.push n for n in arguments
        actors

      pop: -> actors.pop()

    @test = do => # @ ~ Actor class

    constructor: (@el, @property, @limit, @increment, @trigger) ->
      # Maybe I should build a map from scroll-top values to their corresponding cssProperty values.
      actors = Actor.actors # alias to class object
      actors.add @

    move: -> # @ ~ Actor instance
      return => # @ ~ Actor instance
        @el.css(@property, (@el.css @property) + @increment)
  
  findPositionOfElement: ->
    (@el_top - scroll_top + @el_height) / (scroll_bottom - scroll_top + @el_height) # returns % of element on screen

  isElFullyVisible: ->
    if (scroll_bottom - @el_height) > @el_top > scroll_top
      @el.trigger 'prlx:fullyVisible'
      return true

  isElPartiallyVisible: ->
    if scroll_bottom > @el_top > (scroll_top - @el_height)
      @el.trigger 'prlx:partiallyVisible'
      return true

  # findPositionOfPageScrolled: -> scroll_top / (document_height - window_height)
  
  # isFunction: (obj) -> return !!(obj and obj.constructor and obj.call and obj.apply) # from _
  
  # isObject: (obj) -> return obj is Object(obj) # from _

(($) ->
  $.fn.prlx = (options, fn) ->
    $.each this, ->
      new Prlx($(this),options)
)(jQuery)
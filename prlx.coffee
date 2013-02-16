class prlx
  constructor: (@el, @options, fn) ->
    # Initialize & cache variables
    $window = $(window)
    $document = $(document)

    @vendor_prefixes    =   ["-webkit-","-moz-","-ms-","-o-"]
    @prefixed_elements  =   ["border-radius","transform","perspective","perspective-origin","box-shadow","background-size"]
    @document_height    =   $document.height()
    @window_height      =   $window.height()
    @scroll_top         =   $window.scrollTop()
    @scroll_bottom      =   @scroll_top + @window_height
    @el_top             =   @el.offset().top
    @el_height          =   @el.height()
    @running            =   false
    @movers             =   []

    # if user resizes window, cache the new window height.
    $window.on 'resize', =>
      @window_height = $window.height()

    # if user scrolls, cache the new scrollY value for use later and see if a frame should be rendered.
    $window.on 'scroll', =>
      @scroll_top = $window.scrollTop()
      @scroll_bottom = @scroll_top + @window_height
      @requestFrameIfNecessary()

    for prop,val of @options
      @movers.push new @Mover(prop,val)

    console.log 'movers is', @movers

  requestFrameIfNecessary: =>
    if not @running
      requestAnimationFrame(@move)
    @running = true

  # move: (prop,val,increment_by) =>
  #   @el.trigger 'prlx:readyToMove'
  #   @running = false

  #   if @findPositionOfElement() is @trigger_at
  #     thing
  
  Mover: (prop,val) ->
    options = val.split " "
    
    start_at = options[0]
    end_at = options[1]
    increment_by = options[2]
    trigger_at = options[3]

    # somehow, mover instances have to be aware of the scrolling and whether or not they should animate.
    # this might mean that all movement code should be part of the Mover instance. Which makes sense. this would
    # also mean that each mover is responsible for requesting its own animation frame. this might be a perf issue




    

  
  isElFullyVisible: =>
    @el.trigger 'prlx:fullyVisible'
    return true if (@scroll_bottom-@el_height) > @el_top > @scroll_top

  isElPartiallyVisible: =>
    @el.trigger 'prlx:partiallyVisible'
    return true if @scroll_bottom > @el_top > @scroll_top-@el_height

  findPositionOfElement: => (@el_top - @scroll_top + @el_height) / (@scroll_bottom - @scroll_top + @el_height) # returns % of element on screen
  findPositionOfPageScrolled: => @scroll_top / (@document_height - @window_height)

  isFunction: (obj) -> return !!(obj and obj.constructor and obj.call and obj.apply) # from _
  isObject: (obj) -> return obj is Object(obj) # from _


$.fn.prlx = (options, fn) ->
  $.each this, ->
    new prlx($(this),options)
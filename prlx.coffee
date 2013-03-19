class Prlx

  class Actor
    constructor: (@options, @instance) ->
      @instance.el.on 'test', =>
        @instance.queue.push @options.partial_adjustment @test()


    test: ->
      current_el_position = @instance.positionOfElement()

      if current_el_position isnt old_position and @instance.isElPartiallyVisible()
        new_el_position = Math.min(Math.pow(current_el_position,@options.acceleration_rate), 1)
        adjustment = @options.maximum_distance*new_el_position
        console.log @options

      old_position = current_el_position
      return adjustment

  # Initialize & cache private class(?) variables
  vendor_prefixes       =   ["-webkit-","-moz-","-ms-","-o-"]
  prefixed_properties   =   ["border-radius","transform","perspective","perspective-origin","box-shadow","background-size"]

  constructor: (@el, @options, fn) ->
    @window               =   $(window)
    @document             =   $(document)
    @document_height      =   @document.height()
    @window_height        =   @window.height()
    @scroll_top           =   @window.scrollTop()
    @scroll_bottom        =   @scroll_top + @window_height
    @el_top               =   @el.offset().top
    @el_height            =   @el.height()
    @running              =   false
    @queue                =   []
    @actors               =   []

    # Parse options object
    for property,val of options
      args = val.match /\S+/g

      number = args[0].match /(\d+)([a-zA-Z]+)/i
      console.log number

      @actors.push new Actor
        el: @el
        property: property
        maximum_distance: number[1]
        unit: number[2]
        acceleration_rate: args[1]
        trigger: args[2]
        partial_adjustment: @computeAdjustment(property, number[2])
      , @

    @window.on 'resize', => @window_height = @window.height()

    # if user scrolls, cache the new scrollY value for use later and see if a frame should be rendered.
    @window.on 'scroll', (@event) =>
      @scroll_top = @window.scrollTop()
      @scroll_bottom = @scroll_top + @window_height

      @el.trigger 'test'

      if not @running
        requestAnimationFrame => # => @ ~ prlx instance
          if @queue.length
            @queue.pop()
          @running = false
      @running = true

  computeAdjustment: (property, unit) ->
    return (adjustment) =>
      if prefixed_properties.indexOf(property) >= 0 # if property is one of the css properties that requires a prefix
        if property is 'rotate' or property is 'skew' or property is 'rotate'
          @el.css
            "transform": "#{property}(#{adjustment}#{unit if unit else 'px'})"
            "-moz-transform": "#{property}(#{adjustment}#{unit if unit else 'px'})"
            "-webkit-transform": "#{property}(#{adjustment}#{unit if unit else 'px'})"
            "-ms-transform": "#{property}(#{adjustment}#{unit if unit else 'px'})"
        else
          @el.css
            "transform": adjustment
            "-moz-transform": adjustment
            "-webkit-transform": adjustment
            "-ms-transform": adjustment
      else
        @el.css(property, "#{adjustment}px")

  positionOfElement: ->
    (@el_top - @scroll_top + @el_height) / (@scroll_bottom - @scroll_top + @el_height) # returns % of element on screen

  isElFullyVisible: ->
    if (@scroll_bottom - @el_height) > @el_top > @scroll_top
      @el.trigger 'prlx:fullyVisible'
      return true

  isElPartiallyVisible: ->
    if @scroll_bottom > @el_top > (@scroll_top - @el_height)
      @el.trigger 'prlx:partiallyVisible'
      return true

  positionOfPageScrolled: -> @scroll_top / (@document_height - @window_height)
  isFunction: (obj) -> return !!(obj and obj.constructor and obj.call and obj.apply) # from _
  isObject: (obj) -> return obj is Object(obj) # from _

(($) ->
  $.fn.prlx = (options, fn) ->
    $.each this, ->
      new Prlx($(this),options)
      # new Prlx new Actor $(this),options
)(jQuery)
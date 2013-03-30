class Prlx

  class Actor
    constructor: (@options, @instance) ->
      @old_position

      @instance.el.bind 'test', =>
        adjustment = @test()

        if adjustment
          @instance.queue.push @options.partial_adjustment adjustment

    test: =>
      current_el_position = @instance.positionOfElement()

      if current_el_position isnt @old_position and @instance.isElPartiallyVisible()
        new_el_position = Math.min(Math.pow(current_el_position,@options.acceleration_rate), 1)
        adjustment = @options.maximum_distance*new_el_position
      else
        return false

      @old_position = current_el_position

      return adjustment

  # Initialize & cache private class(?) variables
  vendor_prefixes       =   ["-webkit-","-moz-","-ms-","-o-"]

  prefixed_properties   =   {
                             "border-radius": true,
                             "transform": true,
                             "perspective": true,
                             "perspective-origin": true,
                             "box-shadow": true,
                             "background-size": true
                            }

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

      number = args[0].match /[1-9](?:\d{0,2})(?:,\d{3})*(?:\.\d*[1-9])?|0?\.\d*[1-9]|0/g
      unit = args[0].match /[a-z]+/ig

      @actors.push new Actor
        el: @el
        property: property
        maximum_distance: number
        unit: unit || undefined
        acceleration_rate: args[1]
        trigger: args[2]
        partial_adjustment: @computeAdjustment(property, unit)
      , @

    @window.on 'resize', => @window_height = @window.height()

    # if user scrolls, cache the new scrollY value for use later and see if a frame should be rendered.
    @window.on 'scroll', (@event) =>
      @scroll_top = @window.scrollTop()
      @scroll_bottom = @scroll_top + @window_height

      @el.trigger 'test'

      if not @running
        requestAnimationFrame => # => @ ~ prlx instance
          while @queue.length
            @queue.pop()
          @running = false
      @running = true

  computeAdjustment: (property, unit) ->
    return (adjustment) =>
      if prefixed_properties[property]
        @el.css
          "transform": adjustment
          "-moz-transform": adjustment
          "-webkit-transform": adjustment
          "-ms-transform": adjustment

      else if property is 'rotate' or property is 'skew' or property is 'scale'
        # now = -> performance.now()
        # start = now()

        @el.css
          "transform": "#{property}(#{adjustment}#{unit || ''})"
          "-moz-transform": "#{property}(#{adjustment}#{unit || ''})"
          "-webkit-transform": "#{property}(#{adjustment}#{unit || ''})"
          "-ms-transform": "#{property}(#{adjustment}#{unit || ''})"

      else
        @el.css(property, "#{adjustment}px")



  positionOfElement: =>
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
define ["jquery"], ($) ->
  class Actor # just a class used mainly for book-keeping and event bindings
    constructor: (options, prlx) ->
      _.extend @, options

      $(window).on 'resize ready', =>
        @el_top = $(@el).offset().top
        @make_adjustment(prlx.test @)

  class Prlx
    prefix = do -> # http://davidwalsh.name/vendor-prefix
      styles = window.getComputedStyle(document.documentElement, '')
      pre = (Array.prototype.slice.call(styles).join('').match(/-(moz|webkit|ms)-/) or (styles.OLink is '' and ['', 'o']))[1]
      "-#{pre}-"

    prefixed_properties   =   {
                               "border-radius": true,
                               "transform": true,
                               "perspective": true,
                               "perspective-origin": true,
                               "box-shadow": true,
                               "background-size": true
                              }
    document_height       =   $(document).height()
    window_height         =   $(window).height()
    scroll_top            =   $(window).scrollTop()
    scroll_bottom         =   scroll_top + window_height

    constructor: (elements, options, fn) ->
      @window               =   $(window)
      actors                =   []
      running               =   false

      # Parse options object
      for property,val of options
        args = val.match /\S+/g
        start = args[0].match /-?\d+(\.\d+)?/g # matches signed decimals only
        end = args[1].match /-?\d+(\.\d+)?/g
        unit = args[0].match /[a-z]+/ig

        for el in elements
          actors.push new Actor
            el: $(el)
            el_top: $(el).offset().top
            el_height: $(el).height()
            property: property
            start: start
            end: end
            unit: unit || undefined
            acceleration: args[1]
            trigger: args[2]
            make_adjustment: @computeAdjustment(property, unit, $(el))
          , @

      @window.on 'resize', => window_height = @window.height()

      # if user scrolls, cache the new scrollY value for use later and see if a frame should be rendered.
      @window.on 'scroll', (event) =>
        scroll_top = @window.scrollTop()
        scroll_bottom = scroll_top + window_height

        if not running
          requestAnimationFrame => # => @ ~ prlx instance
            actor.make_adjustment(@test actor) for actor in actors
            running = false
        running = true

    test: (actor) =>
      current_el_position = (@positionOfElement.call actor)

      if current_el_position isnt old_position and @isElPartiallyVisible.call actor
        # new_el_position = Math.min(Math.pow(current_el_position,actor.acceleration_rate), 1)
        # new_el_position = current_el_position
        # new_el_position = Math.min(current_el_position*actor.start,current_el_position*actor.end)
        # adjustment = actor.end*(new_el_position)
      else
        return false

      old_position = current_el_position

      # return adjustment

    computeAdjustment: (property, unit, el) ->
      (adjustment) ->
        if adjustment
          if prefixed_properties[property]
            el.css "#{prefix}property", adjustment
          else if property is 'rotate' or property is 'skew' or property is 'scale'
            el.css "#{prefix}transform", "#{property}(#{adjustment}#{unit || ''})"
          else
            el.css(property, "#{adjustment}#{unit}")

    positionOfElement: ->
      (@el_top - scroll_top + @el_height) / (scroll_bottom - scroll_top + @el_height) # returns % of element on screen

    isElFullyVisible: ->
      ((scroll_bottom - @el_height) > @el_top > scroll_top)

    isElPartiallyVisible: ->
      (scroll_bottom > @el_top > (scroll_top - @el_height))

  (($) ->
    $.fn.prlx = (options, fn) ->
      new Prlx($(this),options)
  )(jQuery)
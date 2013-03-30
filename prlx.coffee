prefix = do -> # http://davidwalsh.name/vendor-prefix
  styles = window.getComputedStyle(document.documentElement, '')
  pre = (Array.prototype.slice.call(styles).join('').match(/-(moz|webkit|ms)-/) or (styles.OLink is '' and ['', 'o']))[1]
  "-#{pre}-"

class Prlx
  # Initialize & cache private class(?) variables
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

  constructor: (el, options, fn) ->
    console.log prefix
    @window               =   $(window)
    running               =   false
    actors                =   []

    # Parse options object
    for property,val of options
      args = val.match /\S+/g

      number = args[0].match /[1-9](?:\d{0,2})(?:,\d{3})*(?:\.\d*[1-9])?|0?\.\d*[1-9]|0/g
      unit = args[0].match /[a-z]+/ig

      actors.push
        el: el
        el_top: el.offset().top
        el_height: el.height()
        property: property
        maximum_distance: number
        unit: unit || undefined
        acceleration_rate: args[1]
        trigger: args[2]
        partial_adjustment: @computeAdjustment(property, unit, el)

    @window.on 'resize', => @window_height = @window.height()

    # if user scrolls, cache the new scrollY value for use later and see if a frame should be rendered.
    @window.on 'scroll', (event) =>
      scroll_top = @window.scrollTop()
      scroll_bottom = scroll_top + window_height

      if not running
        requestAnimationFrame => # => @ ~ prlx instance

          for actor in actors
            adjustment = @test(actor)
            if adjustment
              actor.partial_adjustment(adjustment)

          running = false
      running = true

  test: (actor) =>
    current_el_position = @positionOfElement.call actor

    if current_el_position isnt old_position and @isElPartiallyVisible.call actor
      new_el_position = Math.min(Math.pow(current_el_position,actor.acceleration_rate), 1)
      adjustment = actor.maximum_distance*new_el_position
    else
      return false

    old_position = current_el_position

    return adjustment

  computeAdjustment: (property, unit, el) ->
    if prefixed_properties[property]
      (adjustment) -> el.css "#{prefix}property", adjustment

    else if property is 'rotate' or property is 'skew' or property is 'scale'
      (adjustment) -> el.css "#{prefix}transform", "#{property}(#{adjustment}#{unit || ''})"

    else
      (adjustment) -> el.css(property, "#{adjustment}px")

  positionOfElement: ->
    # returns float
    (@el_top - scroll_top + @el_height) / (scroll_bottom - scroll_top + @el_height) # returns % of element on screen

  isElFullyVisible: ->
    # returns bool
    ((scroll_bottom - @el_height) > @el_top > scroll_top)

  isElPartiallyVisible: ->
    # returns bool
    (scroll_bottom > @el_top > (scroll_top - @el_height))

  # positionOfPageScrolled: ->
  #   (scroll_top / (document_height - window_height))

  isFunction: (obj) -> return !!(obj and obj.constructor and obj.call and obj.apply) # from _

  isObject: (obj) -> return obj is Object(obj) # from _

(($) ->
  $.fn.prlx = (options, fn) ->
    $.each this, ->
      new Prlx($(this),options)
)(jQuery)
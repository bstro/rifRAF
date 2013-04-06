# define ["jquery"], ($) ->
class Actor
  @actors ||= {}
  @_id = 0

  constructor: (el, options) ->
    @actions ||= []
    Actor._id++

    if Actor.actors[el.prlx_id]
      @parseOptions options, Actor.actors[el.prlx_id].actions
    else
      Actor.actors["c#{Actor._id}"] = @
      el.prlx_id = "c#{Actor._id}"
      @parseOptions options, @actions

    console.log Actor.actors

  parseOptions: (options, collection) ->
    for property,val of options
      args = val.match /\S+/g
      start = args[0].match /-?\d+(\.\d+)?/g # matches signed decimals only.
      stop = args[1].match /-?\d+(\.\d+)?/g
      unit = args[0].match /[a-z]+/ig

      collection.push
        'property': property
        'start'   : start?[0]
        'stop'    : stop?[0]
        'unit'    : unit?[0]

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

    elements.each -> new Actor @, options

    @window.on 'resize', => window_height = @window.height()

    @window.on 'scroll', (event) =>
      scroll_top = @window.scrollTop()
      scroll_bottom = scroll_top + window_height

      if not running
        requestAnimationFrame => # => @ ~ prlx instance
          @make_adjustment(@test actor) for actor in Actor.actors
          running = false
      running = true

  test: (actor) =>
    current_el_position = (@yPositionOfElement.call actor)

    delta = actor.start - actor.end

    if current_el_position isnt old_position # and @isElPartiallyVisible.call actor
      # new_el_position = Math.min(Math.pow(current_el_position,actor.acceleration_rate), 1)
      adjustment = current_el_position*delta
    else
      return false

    old_position = current_el_position

    return adjustment

  computeAdjustment: (property, unit, el) ->
    (adjustment) ->
      if adjustment
        if prefixed_properties[property]
          el.css "#{prefix}property", adjustment
        else if property is 'rotate' or property is 'skew' or property is 'scale'
          el.css "#{prefix}transform", "#{property}(#{adjustment}#{unit || ''})"
        else
          el.css(property, "#{adjustment}#{unit}")

  yPositionOfElement: ->
    (@el_top - scroll_top + @el_height) / (scroll_bottom - scroll_top + @el_height) # returns % of element on screen

  isElFullyVisible: ->
    ((scroll_bottom - @el_height) > @el_top > scroll_top)

  isElPartiallyVisible: ->
    (scroll_bottom > @el_top > (scroll_top - @el_height))

(($) ->
  $.fn.prlx = (options) ->
    new Prlx($(this),options)
)(jQuery)
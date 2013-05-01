prefix = do -> # modified -> http://davidwalsh.name/vendor-prefix
  styles = window.getComputedStyle(document.documentElement, '')
  pre = (Array.prototype.slice.call(styles).join('').match(/-(moz|webkit|ms)-/) or (styles.OLink is '' and ['', 'o']))[1]
  return pre

shim = do ->
  unless window.requestAnimationFrame
    last_time = 0;
    window.requestAnimationFrame = window[prefix+"RequestAnimationFrame"]
    window.cancelAnimationFrame = window[prefix+"CancelAnimationFrame"] || window[prefix+"CancelRequestAnimationFrame"]

    unless window.requestAnimationFrame
      window.requestAnimationFrame = (callback, element) ->
        currTime = new Date().getTime()
        timeToCall = Math.max(0, 16 - (currTime - lastTime))
        id = window.setTimeout(->
          callback currTime + timeToCall
        , timeToCall)
        lastTime = currTime + timeToCall
        id

    unless window.cancelAnimationFrame
      window.cancelAnimationFrame = (id) -> clearTimeout id

# ADD CALLBACK FUNCTION OPTION TO BYPASS ACTOR PARSING
# ADD SUPPORT FOR COLOR TRANSITIONS
# ADD SUPPORT FOR BACKGROUND POSITION.
# ADD CUBIC BEZIER EASING FUNCTIONS

class Actor
  @actors ||= {}
  @_id = 0

  constructor: (@el, options) ->
    Actor._id++
    @actions ||= []

    if Actor.actors[@el[0].rifraf_id] # If actor already exists for this element
      @parseOptions options, Actor.actors[@el[0].rifraf_id].actions

    else # If this is a new actor
      Actor.actors["c#{Actor._id}"] = @
      @el[0].rifraf_id = "c#{Actor._id}"
      @parseOptions options, @actions

  parseOptions: (optionsArr, collection) ->
    # make this whole function recursive?
    for options in optionsArr
      a = {
        'el':            @el
        'property':      options.property
        'el_height':     @el.height()
        'start':         parseFloat((options.start?.match?(/-?\d+(\.\d+)?/g))?[0], 10) or parseFloat(options.start, 10) or 0 # matches signed decimals
        'stop':          parseFloat((options.stop?.match?(/-?\d+(\.\d+)?/g))?[0], 10) or parseFloat(options.stop, 10) or 0 # matches signed decimals
        'delta':         (parseFloat(options.stop, 10) - parseFloat(options.start, 10))
        'unit':          ((options.start?.match?(/[a-z]+/ig))?[0]) or (options.stop?.match?(/[a-z]+/ig))?[0] or '' # matches consecutive letters
        'scroll_begin':  (parseInt(options.scrollBegin)/100 if 0 <= parseInt(options.scrollBegin) <= 100)
        'scroll_end':    (parseInt(options.scrollEnd)/100 if 0 <= parseInt(options.scrollEnd) <= 100)
        'timing':        options.timing
        'weight':        options.weight
      }
      collection.push a


class Director # creates a singleton instance of rifRAF. If one already exists, it just adds new actors.
  @getInstance: (elements, options) ->
    @_instance = new @(arguments...) unless @_instance
    elements.each -> new Actor $(@), options


class rifRAF extends Director
  @callbacks ||= []
  prefixed_properties   =   {"border-radius": true, "transform": true, "perspective": true, "perspective-origin": true, "box-shadow": true, "background-size": true }
  modifiers             =   {"matrix": "transform", "translate": "transform", "translateX": "transform", "translateY": "transform", "scale": "transform", "scaleX": "transform", "scaleY": "transform", "rotate": "transform", "skewX": "transform", "skewY": "transform", "matrix3d": "transform", "translate3d": "transform", "translateZ": "transform", "scale3d": "transform", "scaleZ": "transform", "rotate3d": "transform", "rotateX": "transform", "rotateY": "transform", "rotateZ": "transform", "perspective": "transform"}
  document_height       =   $(document).height()
  window_height         =   $(window).height()
  scroll_top            =   $(window).scrollTop()
  scroll_bottom         =   scroll_top + window_height

  constructor: (elements, options, fn) ->
    @window               =   $(window)
    @document             =   $(document)
    running               =   false

    $(document).ready => # This is a hacky way of rendering the initial state, since the rifRAF class has no way of knowing when all the actors have actually been added.
      @render(actor.el, @test(actor)) for k,actor of Actor.actors

    @window.on 'resize', => window_height = @window.height()

    $(document).on 'scroll', (event) =>
      scroll_top = @window.scrollTop()
      scroll_bottom = scroll_top + window_height

      unless running
        requestAnimationFrame =>
          @render(actor.el, @test(actor)) for k,actor of Actor.actors
          callback() for callback in rifRAF.callbacks if rifRAF.callbacks.length
          running = false
      running = true

  test: (actor) ->
    adjustments = {}

    if actor?.actions
      for k,action of actor.actions
        current_el_position = @clamp(@yPositionOfActor.call(action), 0, 1)
        adjustment = action.stop - (action.delta * current_el_position)

        if (property = modifiers[action.property])
          adjustments[property] ||= ""
          adjustments[property] += "#{action.property}(#{adjustment}#{action.unit or ''}) "

        else
          adjustments[action.property] = "#{adjustment}#{action['unit'] or ''}"

    return adjustments

  render: (el, adjustments) -> el.css adjustments

  yPositionOfActor: (actor) -> # returns (float) percentage of element on screen
    scroll_top = (scroll_top + ((1.0-@scroll_end)*window_height) + @el_height) if @scroll_end
    scroll_bottom = (scroll_bottom - ((@scroll_begin)*window_height)) if @scroll_begin
    (@el.offset().top - scroll_top + @el_height) / (scroll_bottom - scroll_top + @el_height)

  isElFullyVisible: -> # returns (bool) whether or not the top and bottom of the element is within the visible browser frame
    ((scroll_bottom - @el_height) > @el.offset().top > scroll_top)

  isElPartiallyVisible: -> # returns (bool) whether or not the element is partially within the visible browser frame
    (scroll_bottom > @el.offset().top > (scroll_top - @el_height))

  clamp: (val, min, max) -> Math.max(min, Math.min(max, val))

(($) ->

  $.extend
    rifraf:
      add: (fn) ->
        rifRAF.callbacks.push fn # adds arbitrary functions to be ran inside rifRAF's RAF callback. Not sure if this is actually optimizing anything.

  $.fn.extend
    rifraf: (options) ->
      rifRAF.getInstance($(this),options)

)(jQuery)
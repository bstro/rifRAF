(($) ->
  $.extend
    rifraf:
      add: (fn) ->
        rifRAF.callbacks.push fn # adds arbitrary functions to be ran inside rifRAF's RAF callback. Not sure if this is actually optimizing anything.

  $.fn.extend
    rifraf: (options) ->
      rifRAF.getInstance($(this),options)

)(jQuery)

class Director
  # Creates a singleton instance of rifRAF. If one already exists, it just adds new actors.
  # I keep forgetting how this works; probably needs to be refactored.
  @getInstance: (elements, options) ->
    @_instance or= new @(arguments...)
    elements.each -> new Actor @, options

class rifRAF extends Director
  @callbacks ||= []
  document_height      =   document.height
  window_height        =   window.innerHeight
  scroll_top           =   window.scrollY
  scroll_bottom        =   scroll_top + window_height

  constructor: (elements, options, fn) ->
    running = false

    $(document).ready => @render(actor.el, @test(actor)) for k,actor of Actor.actors

    window.addEventListener 'resize', => window_height = window.screen.height

    document.addEventListener 'scroll', (event) =>
      scroll_top = window.scrollY
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
        adjustment = action.stop - (action.delta * (action.easing?.compute(current_el_position) or current_el_position))

        if modifiers[action.property]
          adjustments[action.prefixed] ||= ""
          adjustments[action.prefixed] += "#{action.property}(#{adjustment}#{action.unit or ''}) "

        else
          adjustments[action.prefixed] = "#{adjustment}#{action['unit'] or ''}"

    return adjustments

  render: (el, adjustments) ->
    $(el).css adjustments
    # el.style[property] = value for property,value of adjustments

  yPositionOfActor: -> # returns (float) percentage of element on screen
    @el_offset = window.pageYOffset + @ref.getBoundingClientRect().top - document.documentElement.clientTop
    scroll_top = (scroll_top + ((1.0-@scroll_end)*window_height) + @el_height) if @scroll_end
    scroll_bottom = (scroll_bottom - ((@scroll_begin)*window_height)) if @scroll_begin

    (@el_offset - scroll_top + @el_height) / (scroll_bottom - scroll_top + @el_height)

  clamp: (val, min, max) -> Math.max(min, Math.min(max, val))

class Actor
  @actors ||= {}
  @_id = 0

  getActor = do ->
    @actors

  constructor: (@el, options) ->
    Actor._id++
    @actions ||= []

    if Actor.actors[@el.rifraf_id] # If actor already exists for this element
      @parseOptions options, Actor.actors[@el.rifraf_id].actions

    else # If this is a new actor
      Actor.actors["c#{Actor._id}"] = @
      @el.rifraf_id = "c#{Actor._id}"
      @parseOptions options, @actions

  parseOptions: (optionsArr, collection) ->
    for options in optionsArr
      action = {
        'el':            @el
        'ref':           options.relativeTo?[0] or @el
        'el_height':     @el.offsetHeight
        'el_offset':     window.pageYOffset + @el.getBoundingClientRect().top - document.documentElement.clientTop
        'property':      options.property
        'prefixed':      get_prefix_for_property(modifiers[options.property]) or get_prefix_for_property(options.property)
        'start':         parseFloat((options.start?.match?(/-?\d+(\.\d+)?/g))?[0], 10) or parseFloat(options.start, 10) or 0 # matches signed decimals
        'stop':          parseFloat((options.stop?.match?(/-?\d+(\.\d+)?/g))?[0], 10) or parseFloat(options.stop, 10) or 0 # matches signed decimals
        'delta':         (parseFloat(options.stop, 10) - parseFloat(options.start, 10))
        'unit':          ((options.start?.match?(/[a-z]+/ig))?[0]) or (options.stop?.match?(/[a-z]+/ig))?[0] or '' # matches consecutive letters
        'scroll_begin':  (parseInt(options.scrollBegin, 10)/100 if 0 <= parseInt(options.scrollBegin, 10) <= 100)
        'scroll_end':    (parseInt(options.scrollEnd, 10)/100 if 0 <= parseInt(options.scrollEnd, 10) <= 100)
        'easing':        do -> new KeySpline options.easing[0], options.easing[1], options.easing[2], options.easing[3] if options.easing
      }
      collection.push action

class KeySpline # https://gist.github.com/gre/1926947
  A = (aA1, aA2) -> 1.0 - 3.0 * aA2 + 3.0 * aA1
  B = (aA1, aA2) -> 3.0 * aA2 - 6.0 * aA1
  C = (aA1) -> 3.0 * aA1
  CalcBezier = (aT, aA1, aA2) -> ((A(aA1, aA2) * aT + B(aA1, aA2)) * aT + C(aA1)) * aT # Returns x(t) given t, x1, and x2, or y(t) given t, y1, and y2.
  GetSlope = (aT, aA1, aA2) -> 3.0 * A(aA1, aA2) * aT * aT + 2.0 * B(aA1, aA2) * aT + C(aA1) # Returns dx/dt given t, x1, and x2, or dy/dt given t, y1, and y2.

  constructor: (@mX1, @mY1, @mX2, @mY2) ->

  compute: (aX) ->
    return aX if @mX1 is @mY1 and @mX2 is @mY2 # linear
    CalcBezier(@getTForX(aX), @mY1, @mY2)

  getTForX: (aX) ->
    aGuessT = aX
    i = 0
    while i < 4 # Newton Raphson iteration
      currentSlope = GetSlope(aGuessT, @mX1, @mX2)
      return aGuessT if currentSlope is 0.0
      currentX = CalcBezier(aGuessT, @mX1, @mX2) - aX
      aGuessT -= currentX / currentSlope
      ++i
    return aGuessT

get_prefix_for_property = (property) ->
  _this = get_prefix_for_property
  _this.prefixed_properties ||=
    "border-radius": ['webkit']
    "transform": ['webkit', 'moz', 'ms', 'o']
    "perspective": ['webkit','moz','ms']
    "perspective-origin": ['webkit','moz','ms']
    "box-shadow": ['webkit']
    "background-size": ['webkit']

  property = "-#{prefix}-#{property}" if _this.prefixed_properties[property]
  return property

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

modifiers =
  "matrix"      :  "transform"
  "translate"   :  "transform"
  "translateX"  :  "transform"
  "translateY"  :  "transform"
  "scale"       :  "transform"
  "scaleX"      :  "transform"
  "scaleY"      :  "transform"
  "rotate"      :  "transform"
  "skewX"       :  "transform"
  "skewY"       :  "transform"
  "matrix3d"    :  "transform"
  "translate3d" :  "transform"
  "translateZ"  :  "transform"
  "scale3d"     :  "transform"
  "scaleZ"      :  "transform"
  "rotate3d"    :  "transform"
  "rotateX"     :  "transform"
  "rotateY"     :  "transform"
  "rotateZ"     :  "transform"
  "perspective" :  "transform"
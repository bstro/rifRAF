# ADD SUPPORT FOR BACKGROUND POSITION.

class Actor
  @actors ||= {}
  @_id = 0

  constructor: (@el, options) ->
    Actor._id++
    @actions ||= []

    parseOptions = (optionsArr, collection) =>
      for options in optionsArr
        a = {
          'property':      options.property,
          'el_top':        @el.offset().top,
          'el_height':     @el.height(),
          'start':         (options.start?.match(/-?\d+(\.\d+)?/g))[0], # matches signed decimals
          'stop':          (options.stop?.match(/-?\d+(\.\d+)?/g))[0], # matches signed decimals
          'unit':          (options.start?.match(/[a-z]+/ig))?[0] or (options.stop?.match(/[a-z]+/ig))?[0], # matches consecutive letters
          'scroll_begin':  (parseInt(options.scrollBegin)/100 if 0 < parseInt(options.scrollBegin) < 100),
          'scroll_end':    (parseInt(options.scrollEnd)/100 if 0 < parseInt(options.scrollEnd) < 100),
          'timing':        options.timing
        }

        collection.push a

    if Actor.actors[@el[0].rifraf_id] # If actor already exists for this element
      parseOptions options, Actor.actors[@el[0].rifraf_id].actions

    else # If this is a new actor
      Actor.actors["c#{Actor._id}"] = @
      @el[0].rifraf_id = "c#{Actor._id}"
      parseOptions options, @actions

class Director # creates a singleton instance of rifRAF. If one already exists, it just adds new actors.
  @getInstance: (elements, options, fn) ->
    if @_instance
      elements.each -> new Actor $(@), options
    else
      @_instance = new @(arguments...)

class rifRAF extends Director
  prefix = do -> # modified -> http://davidwalsh.name/vendor-prefix
    styles = window.getComputedStyle(document.documentElement, '')
    pre = (Array.prototype.slice.call(styles).join('').match(/-(moz|webkit|ms)-/) or (styles.OLink is '' and ['', 'o']))[1]
    return pre

  unless window.requestAnimationFrame
    window.requestAnimationFrame = window[prefix+"RequestAnimationFrame"]
    window.cancelAnimationFrame = window[prefix+"CancelAnimationFrame"] || window[prefix+"CancelRequestAnimationFrame"]

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

    elements.each -> new Actor $(@), options

    $(document).ready =>
      @render(actor.el, @test(actor)) for k,actor of Actor.actors

    @window.on 'resize', => window_height = @window.height()

    $(document).on 'scroll', (event) =>
      scroll_top = @window.scrollTop()
      scroll_bottom = scroll_top + window_height

      if not running
        requestAnimationFrame => # => @ ~ rifraf instance
          @render(actor.el, @test(actor)) for k,actor of Actor.actors
          running = false
      running = true

  test: (actor) ->
    adjustments = {}

    for k,action of actor.actions
      current_el_position = @clamp(@yPositionOfElement.call(action), 0, 1)
      delta = parseFloat(action.stop,10) - parseFloat(action.start,10)
      adjustment = (delta * current_el_position) + parseFloat(action.start,10)

      if (property = modifiers[action.property])
        adjustments[property] ||= ""
        adjustments[property] += "#{action.property}(#{adjustment}#{action.unit or ''}) "
      else
        adjustments[action.property] = "#{adjustment}#{action['unit'] or ''}"
    return adjustments

  render: (el, adjustments) -> el.css adjustments

  yPositionOfElement: ->
    console.log @scroll_end, @scroll_begin
    scroll_top = (scroll_top + ((1.0-@scroll_end)*window_height) + @el_height/2) if @scroll_end
    scroll_bottom = (scroll_bottom - ((@scroll_begin)*window_height)) if @scroll_begin

    (@el_top - scroll_top + @el_height) / (scroll_bottom - scroll_top + @el_height) # returns % of element on screen

  isElFullyVisible: -> ((scroll_bottom - @el_height) > @el_top > scroll_top)
  isElPartiallyVisible: -> (scroll_bottom > @el_top > (scroll_top - @el_height))
  clamp: (val, min, max) -> Math.max(min, Math.min(max, val))

(($) ->
  $.fn.extend
    rifraf: (options) ->
      rifRAF.getInstance($(this),options)
)(jQuery)
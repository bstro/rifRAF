# define ["jquery"], ($) ->
class Actor
  @actors ||= {}
  @_id = 0

  constructor: (@el, options) ->
    Actor._id++
    @actions ||= []
    @attributes ||= {}

    @attributes['el_height'] = @el.height()
    @attributes['el_top'] = @el.offset().top

    parseOptions = (options, collection) ->
      for property,val of options
        args = val.match /\S+/g
        start = args[0].match /-?\d+(\.\d+)?/g # matches signed decimals
        stop = args[1].match /-?\d+(\.\d+)?/g # matches signed decimals
        unit = args[0].match /[a-z]+/ig # matches consecutive letters

        a = {}
        a['property'] = property if property
        a['start']    = start[0] if start
        a['stop']     = stop[0] if stop
        a['unit']     = unit[0] if unit

        collection.push a

    if Actor.actors[@el[0].prlx_id] # If actor already exists for this element
      parseOptions options, Actor.actors[@el[0].prlx_id].actions

    else # If this is a new actor
      Actor.actors["c#{Actor._id}"] = @
      @el[0].prlx_id = "c#{Actor._id}"
      parseOptions options, @actions

class Director
  @getInstance: (elements, options, fn) ->
    if @_instance
      elements.each -> new Actor $(@), options
    else
      @_instance = new @(arguments...)

class Prlx extends Director
  prefix = do -> # modified -> http://davidwalsh.name/vendor-prefix
    styles = window.getComputedStyle(document.documentElement, '')
    pre = (Array.prototype.slice.call(styles).join('').match(/-(moz|webkit|ms)-/) or (styles.OLink is '' and ['', 'o']))[1]
    return pre

  unless window.requestAnimationFrame
    window.requestAnimationFrame = window[prefix+"RequestAnimationFrame"]
    window.cancelAnimationFrame = window[prefix+"CancelAnimationFrame"] || window[prefix+"CancelRequestAnimationFrame"]

  console.log 'prefix is', prefix

  prefixed_properties   =   {"border-radius": true, "transform": true, "perspective": true, "perspective-origin": true, "box-shadow": true, "background-size": true }
  modifiers             =   {"matrix": "transform", "translate": "transform", "translateX": "transform", "translateY": "transform", "scale": "transform", "scaleX": "transform", "scaleY": "transform", "rotate": "transform", "skewX": "transform", "skewY": "transform", "matrix3d": "transform", "translate3d": "transform", "translateZ": "transform", "scale3d": "transform", "scaleZ": "transform", "rotate3d": "transform", "rotateX": "transform", "rotateY": "transform", "rotateZ": "transform", "perspective": "transform"}
  document_height       =   $(document).height()
  window_height         =   $(window).height()
  scroll_top            =   $(window).scrollTop()
  scroll_bottom         =   scroll_top + window_height

  constructor: (elements, options, fn) ->
    @window               =   $(window)
    running               =   false

    elements.each -> new Actor $(@), options

    @window.on 'resize', => window_height = @window.height()
    @window.on 'scroll', (event) =>
      scroll_top = @window.scrollTop()
      scroll_bottom = scroll_top + window_height

      if not running
        requestAnimationFrame => # => @ ~ prlx instance
          @render(actor.el, @test(actor)) for k,actor of Actor.actors
          running = false
      running = true

  test: (actor) ->
    current_el_position = @yPositionOfElement.call actor.attributes

    adjustments = {}

    for k,action of actor.actions
      delta = action.start - action.stop
      adjustment = current_el_position * delta

      if modifiers[action.property]
        if adjustments[modifiers[action.property]]
          adjustments[modifiers[action.property]] += "#{action.property}(#{adjustment}#{action.unit or ''}) "
        else
          adjustments[modifiers[action.property]] = "#{action.property}(#{adjustment}#{action.unit or ''}) "
      else
        adjustments[action.property] = "#{adjustment}#{action.unit if action.unit}"

    return adjustments

  render: (el, adjustments) -> el.css adjustments

  yPositionOfElement: ->
    (@el_top - scroll_top + @el_height) / (scroll_bottom - scroll_top + @el_height) # returns % of element on screen

  isElFullyVisible: ->
    ((scroll_bottom - @el_height) > @el_top > scroll_top)

  isElPartiallyVisible: ->
    (scroll_bottom > @el_top > (scroll_top - @el_height))

(($) ->
  $.fn.prlx = (options) ->
    Prlx.getInstance($(this),options)
)(jQuery)
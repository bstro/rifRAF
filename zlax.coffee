class zLax
  constructor: (@el, @movement) ->
    @itemTop = @el.offset().top
    @test()

  test: () =>
    requestAnimationFrame(@test)
    @scrollTop = $(window).scrollTop()
    @scrollBottom = @scrollTop + $(window).height()
    position = (@itemTop-@scrollTop)/(@scrollBottom-@scrollTop)
    @movement(@el, position) if position != @_position
    @_position = position

  # Produces a function that shifts the into place as you scroll.
  @shifter: (distance, exp) =>
    return (el,p) =>
      p2 = Math.min(Math.pow(p,exp), 1)
      translate = "translate(0,#{distance*p2}px)"
      el.css
        "-webkit-transform" : translate
        "-moz-transform"    : translate
        "-ms-transform"     : translate
        "transform"         : translate

  @laxRotate: (el,p) ->
    rotate = "rotate(#{90*p}deg)"
    el.css
      "-webkit-transform" : rotate
      "-moz-transform"    : rotate
      "-ms-transform"     : rotate
      "transform"         : rotate

$.fn.zLax = (options = {}) ->
  this.each ->
    new zLax($(this), options)
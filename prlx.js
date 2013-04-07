// Generated by CoffeeScript 1.6.1
(function() {
  var Actor, Director, Prlx,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Actor = (function() {

    Actor.actors || (Actor.actors = {});

    Actor._id = 0;

    function Actor(el, options) {
      var parseOptions;
      this.el = el;
      Actor._id++;
      this.actions || (this.actions = []);
      this.attributes || (this.attributes = {});
      this.attributes['el_height'] = this.el.height();
      this.attributes['el_top'] = this.el.offset().top;
      parseOptions = function(options, collection) {
        var a, args, property, start, stop, unit, val, _results;
        _results = [];
        for (property in options) {
          val = options[property];
          args = val.match(/\S+/g);
          start = args[0].match(/-?\d+(\.\d+)?/g);
          stop = args[1].match(/-?\d+(\.\d+)?/g);
          unit = args[0].match(/[a-z]+/ig);
          a = {};
          if (property) {
            a['property'] = property;
          }
          if (start) {
            a['start'] = start[0];
          }
          if (stop) {
            a['stop'] = stop[0];
          }
          if (unit) {
            a['unit'] = unit[0];
          }
          _results.push(collection.push(a));
        }
        return _results;
      };
      if (Actor.actors[this.el[0].prlx_id]) {
        parseOptions(options, Actor.actors[this.el[0].prlx_id].actions);
      } else {
        Actor.actors["c" + Actor._id] = this;
        this.el[0].prlx_id = "c" + Actor._id;
        parseOptions(options, this.actions);
      }
    }

    return Actor;

  })();

  Director = (function() {

    function Director() {}

    Director.getInstance = function(elements, options, fn) {
      if (this._instance) {
        return elements.each(function() {
          return new Actor($(this), options);
        });
      } else {
        return this._instance = (function(func, args, ctor) {
          ctor.prototype = func.prototype;
          var child = new ctor, result = func.apply(child, args);
          return Object(result) === result ? result : child;
        })(this, arguments, function(){});
      }
    };

    return Director;

  })();

  Prlx = (function(_super) {
    var document_height, modifiers, prefix, prefixed_properties, scroll_bottom, scroll_top, window_height;

    __extends(Prlx, _super);

    prefix = (function() {
      var pre, styles;
      styles = window.getComputedStyle(document.documentElement, '');
      pre = (Array.prototype.slice.call(styles).join('').match(/-(moz|webkit|ms)-/) || (styles.OLink === '' && ['', 'o']))[1];
      return pre;
    })();

    if (!window.requestAnimationFrame) {
      window.requestAnimationFrame = window[prefix + "RequestAnimationFrame"];
      window.cancelAnimationFrame = window[prefix + "CancelAnimationFrame"] || window[prefix + "CancelRequestAnimationFrame"];
    }

    console.log('prefix is', prefix);

    prefixed_properties = {
      "border-radius": true,
      "transform": true,
      "perspective": true,
      "perspective-origin": true,
      "box-shadow": true,
      "background-size": true
    };

    modifiers = {
      "matrix": "transform",
      "translate": "transform",
      "translateX": "transform",
      "translateY": "transform",
      "scale": "transform",
      "scaleX": "transform",
      "scaleY": "transform",
      "rotate": "transform",
      "skewX": "transform",
      "skewY": "transform",
      "matrix3d": "transform",
      "translate3d": "transform",
      "translateZ": "transform",
      "scale3d": "transform",
      "scaleZ": "transform",
      "rotate3d": "transform",
      "rotateX": "transform",
      "rotateY": "transform",
      "rotateZ": "transform",
      "perspective": "transform"
    };

    document_height = $(document).height();

    window_height = $(window).height();

    scroll_top = $(window).scrollTop();

    scroll_bottom = scroll_top + window_height;

    function Prlx(elements, options, fn) {
      var running,
        _this = this;
      this.window = $(window);
      running = false;
      elements.each(function() {
        return new Actor($(this), options);
      });
      this.window.on('resize', function() {
        return window_height = _this.window.height();
      });
      this.window.on('scroll', function(event) {
        scroll_top = _this.window.scrollTop();
        scroll_bottom = scroll_top + window_height;
        if (!running) {
          requestAnimationFrame(function() {
            var actor, k, _ref;
            _ref = Actor.actors;
            for (k in _ref) {
              actor = _ref[k];
              _this.render(actor.el, _this.test(actor));
            }
            return running = false;
          });
        }
        return running = true;
      });
    }

    Prlx.prototype.test = function(actor) {
      var action, adjustment, adjustments, current_el_position, delta, k, _ref;
      current_el_position = this.yPositionOfElement.call(actor.attributes);
      adjustments = {};
      _ref = actor.actions;
      for (k in _ref) {
        action = _ref[k];
        delta = action.start - action.stop;
        adjustment = current_el_position * delta;
        if (modifiers[action.property]) {
          if (adjustments[modifiers[action.property]]) {
            adjustments[modifiers[action.property]] += "" + action.property + "(" + adjustment + (action.unit || '') + ") ";
          } else {
            adjustments[modifiers[action.property]] = "" + action.property + "(" + adjustment + (action.unit || '') + ") ";
          }
        } else {
          adjustments[action.property] = "" + adjustment + (action.unit ? action.unit : void 0);
        }
      }
      return adjustments;
    };

    Prlx.prototype.render = function(el, adjustments) {
      return el.css(adjustments);
    };

    Prlx.prototype.yPositionOfElement = function() {
      return (this.el_top - scroll_top + this.el_height) / (scroll_bottom - scroll_top + this.el_height);
    };

    Prlx.prototype.isElFullyVisible = function() {
      var _ref;
      return ((scroll_bottom - this.el_height) > (_ref = this.el_top) && _ref > scroll_top);
    };

    Prlx.prototype.isElPartiallyVisible = function() {
      var _ref;
      return (scroll_bottom > (_ref = this.el_top) && _ref > (scroll_top - this.el_height));
    };

    return Prlx;

  })(Director);

  (function($) {
    return $.fn.prlx = function(options) {
      return Prlx.getInstance($(this), options);
    };
  })(jQuery);

}).call(this);

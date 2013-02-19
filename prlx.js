(function() {
  var Prlx;

  Prlx = (function() {
    var $document, $window, Actor, Director, document_height, prefixed_elements, scroll_bottom, scroll_top, vendor_prefixes, window_height;

    $window = $(window);
    $document = $(document);

    vendor_prefixes = ["-webkit-", "-moz-", "-ms-", "-o-"];
    prefixed_elements = ["border-radius", "transform", "perspective", "perspective-origin", "box-shadow", "background-size"];
    document_height = $document.height();
    window_height = $window.height();
    scroll_top = $window.scrollTop();
    scroll_bottom = scroll_top + Prlx.window_height;

    function Prlx(el, options, fn) {
      var args, foo, property, val;
      this.el = el;
      this.el_top = this.el.offset().top;
      this.el_height = this.el.height();
      this.running = false;
      for (property in options) {
        val = options[property];
        args = val.match(/\S+/g);
        foo = new Director(new Actor(this.el, property, args[0], args[1], args[2]));
        console.log(foo);
      }
    }

    Director = (function() {
      var _this = this;

      Director.events = (function() {
        $window.on('resize', function() {
          return window_height = $window.height();
        });
        return $window.on('scroll', function(event) {
          Director.event = event;
          scroll_top = $window.scrollTop();
          scroll_bottom = scroll_top + window_height;
          if (!Director.running) {
            requestAnimationFrame(function() {
              Director.stack.pop()();
              return Director.running = false;
            });
          }
          return Director.running = true;
        });
      })();

      function Director(actor) {
        this.actor = actor;
      }

      return Director;

    }).call(this);

    Actor = (function() {
      var _this = this;

      Actor.actors = (function() {
        var actors;
        actors = [];
        return {
          get: function() {
            return actors;
          },
          add: function() {
            var n, _i, _len;
            for (_i = 0, _len = arguments.length; _i < _len; _i++) {
              n = arguments[_i];
              actors.push(n);
            }
            return actors;
          },
          pop: function() {
            return actors.pop();
          }
        };
      })();

      Actor.test = (function() {})();

      function Actor(el, property, limit, increment, trigger) {
        var actors;
        this.el = el;
        this.property = property;
        this.limit = limit;
        this.increment = increment;
        this.trigger = trigger;
        actors = Actor.actors;
        actors.add(this);
      }

      Actor.prototype.move = function() {
        var _this = this;
        return function() {
          return _this.el.css(_this.property, (_this.el.css(_this.property)) + _this.increment);
        };
      };

      return Actor;

    }).call(this);

    Prlx.prototype.findPositionOfElement = function() {
      return (this.el_top - scroll_top + this.el_height) / (scroll_bottom - scroll_top + this.el_height);
    };

    Prlx.prototype.isElFullyVisible = function() {
      var _ref;
      if (((scroll_bottom - this.el_height) > (_ref = this.el_top) && _ref > scroll_top)) {
        this.el.trigger('prlx:fullyVisible');
        return true;
      }
    };

    Prlx.prototype.isElPartiallyVisible = function() {
      var _ref;
      if ((scroll_bottom > (_ref = this.el_top) && _ref > (scroll_top - this.el_height))) {
        this.el.trigger('prlx:partiallyVisible');
        return true;
      }
    };

    return Prlx;

  }).call(this);

  (function($) {
    return $.fn.prlx = function(options, fn) {
      return $.each(this, function() {
        return new Prlx($(this), options);
      });
    };
  })(jQuery);

}).call(this);

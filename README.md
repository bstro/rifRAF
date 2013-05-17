#rifRAF

An animation controller that uses requestAnimationFrame to animate elements as a function of the browser's scroll position.

Can be instantiated like so:

    $(el).rifraf([
      {
        property: 'translateX',             // css property
        start: '50px',                      // css property start value
        stop: '-280px',                     // css property end value
        scrollBegin: 55,                    // percentage of el on screen where animation should begin
        scrollEnd: 95,                      // percentage of el on screen where animation should finish
        easing: [0.645, 0.045, 0.355, 1]    // http://easings.net/
      }
    ]);

Supports animation on multiple CSS properties per element:

    $(element).rifraf([
      {
        property: "scale",
        start: 3,
        stop: 0.8
      }, {
        property: "opacity",
        start: 3,
        stop: 0
      }
    ]);

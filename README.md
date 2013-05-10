#rifRAF

An animation controller, syntactically-similar to CSS.

Can be instantiated like so:

    $(el).rifraf([
      {
        property: 'translateX',
        start: '50px',
        stop: '-280px',
        scrollBegin: 55,
        scrollEnd: 95,
        easing: [0.645, 0.045, 0.355, 1]
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

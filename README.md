#rifRAF

An animation controller, syntactically-similar to CSS.

Can be instantiated like so:

	$('p').prlx({
		"scale": "1.0 3.0",
		"rotate": "120deg 360deg",
		"translateY": "0px -150px",
		"translateX": "0px -150px"
	});

__Warning: the math for calculating the css adjustsments currently doesn't work as expected. You probably shouldn't use this yet.__
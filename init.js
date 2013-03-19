$(function() {
  $('#box2').prlx({
   "margin-left": "450px 2 50%", // maximum_distance, acceleration rate, trigger
   // "margin-left": "3000px 2 onscreen"
   // "transform": …
   // "rotate": …
   // "scale": …
  });

  // $('#box2').prlx({
  //   "opacity": "1 0.01 0%" // limit, increment by, trigger at
  // });

  // $("#box3").prlx({
  //   "rotate": function(distance,path) {
  //
  //   };
  // });

  // moar:

  // $(element).prlx
  // 	"margin-top": ->
  // 		cool custom function

  // $(element).prlx ->
  //	completely custom

  // $(element).prlx(prlx.predefFn)

  // I need to spin off functions for each property declaration. One instance
  // per property that continually watches the start-at point to make animations
  // scrubbable (make this into a boolean option)

});


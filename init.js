$(function() {

  $('.box').prlx({
    "rotate": "120deg 2 onscreen"
    // "rotate": "5deg 1 onscreen #box2" // specifying an element triggers box1's animation only when box2 is onscreen (or 25% or 54% or w/e)
  });

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


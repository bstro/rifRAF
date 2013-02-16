$(function() {

  $('#box1').prlx({
   "margin-top": "0px 150px 1px 50%", // start at, end at, increment by, trigger at on-screen percentage
   "opacity": "0.01 0 1 0%"
  });

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


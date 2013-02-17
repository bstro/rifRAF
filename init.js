$(function() {

  $('#box1').prlx({
   "margin-top": "150px 1px 50%" // limit, increment by, trigger at
  });

  $('#box2').prlx({
    "opacity": "1 0.01 0%" // limit, increment by, trigger at
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


$(function() {
  $('p').prlx({
    "margin-left": "100px 200px",
    // "rotate": "120deg 360deg",
    // "translateY": "0px -150px",
    // "translateX": "0px -150px"
    // "rotate": "5deg 1 onscreen #box2" // specifying an element triggers box1's animation only when box2 is onscreen (or 25% or 54% or w/e)
  });

  // $('#black .box').prlx({
  //   "scale": "0.1 1.2",
  //   "rotate": "120deg 375deg",
  //   "translateY": "0px -140px",
  //   "translateX": "0px -140px"
  //   // "rotate": "5deg 1 onscreen #box2" // specifying an element triggers box1's animation only when box2 is onscreen (or 25% or 54% or w/e)
  // });

  // $('#green .box').prlx({
  //   "scale": "0.1 1.1",
  //   "rotate": "120deg 480deg",
  //   "translateY": "0px -145px",
  //   "translateX": "0px -145px"
  //   // "rotate": "5deg 1 onscreen #box2" // specifying an element triggers box1's animation only when box2 is onscreen (or 25% or 54% or w/e)
  // });

  // $('#box1').prlx({

  // });

  // $('#box1').prlx({
  //   "margin-left": "120px 1 onscreen"
  // })

  // $("#box1").prlx('fade');

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


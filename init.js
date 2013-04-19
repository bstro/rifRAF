$(function() {
  // option 1: send in array of objects
  // option 2: send in event and function

  $('p').rifraf([{
    property: 'rotate',
    start: '0deg',
    stop: '360deg',
    scrollBegin: '50%',
    scrollEnd: '80%',
    timing: [0.645,0.045,0.355,1],
    // trigger: $("#box1")
  }]);

  // $('p').rifraf('onscreen', function() {
  // });
});


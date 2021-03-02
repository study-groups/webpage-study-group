// https://stackoverflow.com/a/36929383/4249785
function ScrollTo(name) {
  ScrollToResolver(document.getElementById(name));
}

function ScrollToResolver(elem) {
  var navbar=document.getElementById("navbar");
  var navHeight=parseInt(navbar.getBoundingClientRect().height);
  if(!navHeight) navHeight=0;

  console.log("navHeight",navHeight);
  var jump = parseInt((elem.getBoundingClientRect().top-navHeight) * .2);
  document.body.scrollTop += jump;
  document.documentElement.scrollTop += jump;
  if (!elem.lastjump || elem.lastjump > Math.abs(jump)) {
    elem.lastjump = Math.abs(jump);
    setTimeout(function() { ScrollToResolver(elem);}, "40");
  } else {
    elem.lastjump = null;
  }
}

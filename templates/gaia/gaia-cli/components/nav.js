
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

curChapter=1;
numOfChapters=11;
chapters=[];
for(var i = 0; i < numOfChapters; i++) {
    chapters.push({"chapter":i, "curPrompt":1});
}

function updateNav(props){
   for(var i = 0; i < navUl.length ; i++) {
      console.log(navUl[0]);
   }
}

function initNav(){
  var navEl=document.getElementById("nav");
  var navUl=document.querySelector("#nav ul");
  for(var i = 0; i < navUl.length ; i++) {
     console.log(navUl[i]);
     navUl.addEventListener("click",handleNavClick);
  }
}

function handleNavClick(evt){
    console.log(evt);
}

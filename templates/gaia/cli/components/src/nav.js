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

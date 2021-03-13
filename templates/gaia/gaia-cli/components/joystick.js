wsInfo=document.querySelector("#ws-info")
var ws = new WebSocket('ws://js.study-groups.org:9200/');
var globalObect={};
ws.onmessage = function(event) {
  o=JSON.parse(event.data);
  wsInfo.innerHTML=`${JSON.stringify(o, null,' ')}`;
  if(o.action=="set--body-text-alt"){
    document.documentElement.style.setProperty("--body-text-alt", 
    `#${o.r}${o.g}${o.b}`);
  }
};

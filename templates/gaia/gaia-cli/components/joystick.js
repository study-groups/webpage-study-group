wsInfo=document.querySelector("#ws-info")
var ws = new WebSocket('ws://js.study-groups.org:9200/');
ws.onmessage = function(event) {
  wsInfo.innerHTML=`event.data:${event.data}`;
  o=JSON.parse(event.data);
  if(o.action=="set--body-text-alt"){
    document.documentElement.style.setProperty("--body-text-alt", 
    `#${o.r}${o.g}${o.b}`);
  }
};

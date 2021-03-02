wsInfo=document.querySelector("#ws-info")
var ws = new WebSocket('ws://js.study-groups.org:9200/');

ws.onmessage = function(event) {
  var msg=`Count is ${event.data}`;
  var d=event.data;
  console.log(msg);
  wsInfo.innerHTML=msg;
 document.documentElement.style.setProperty("--body-text-alt", 
  `#${d}${d}${d}`);
};

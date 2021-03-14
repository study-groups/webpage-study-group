wsInfo=document.querySelector("#ws-info")
var ws = new WebSocket('ws://js.study-groups.org:9200/');
ws.onmessage = function(event) {
  o=JSON.parse(event.data);
  wsInfo.innerHTML=`${JSON.stringify(o, null,' ')}`;
  
  if(o.action=="set--body-text-alt"){
    document.documentElement.style.setProperty("--body-text-alt", 
    `#${o.r}${o.g}${o.b}`);
  }

  if(o.type=="joystick.axis"){
    mapHtml = `<div style="color: var(--body-text);">`
    mapHtml += `x-mapped: ${gMapper.map(o.type,o.x).toFixed(5)}<br>`;
    mapHtml += `y-mapped: ${gMapper.map(o.type,o.y).toFixed(5)}`;
    mapHtml += "</div>"
    wsInfo.innerHTML=wsInfo.innerHTML+mapHtml;
  }
};

function Mapper(){
   var maps={};
   publicInterface = {
      add: function(name,mapToFun) {
          maps[name]=mapToFun;
      },
      get: function(id) {
          return maps[id];
      },
      map:function(id,value){return maps[id](value);}
   }   
   return publicInterface;
}
gMapper=Mapper();
gMapper.add("joystick.axis",function(v){ return v / parseFloat(32767)});

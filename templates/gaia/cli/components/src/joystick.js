wsInfo=document.querySelector("#ws-info")
var ws = new WebSocket('ws://devops.study-groups.org:9200/');
ws.onmessage = function(event) {
  o=JSON.parse(event.data);
  wsInfo.innerHTML=`${JSON.stringify(o, null,' ')}`;

  if(o.action=="set--body-text-alt"){
    document.documentElement.style.setProperty("--body-text-alt",
    `#${o.r}${o.g}${o.b}`);
  }

  if(o.type=="joystick.axis"){
    var x = gMapper.map("joystick.axis",o.x);
    var y = gMapper.map("joystick.axis",o.y);
    var rho =  Math.sqrt( Math.pow(x,2) + Math.pow(y,2) );
    var theta =  Math.atan((-y)/(x))/Math.PI * 180;
    if (x < 0 && y <= 0) theta = theta + 180;
    if (x < 0 && y > 0) theta = theta - 180;

    hue = theta;
    saturation=rho*100;
    level=rho*50;

    document.documentElement.style.setProperty(cssModel.getCur().key,
    `hsl(${hue}, ${saturation}%, ${level}%)`);
    //document.documentElement.style.setProperty(cssModel.getCur().key,
    //`blue`);

    mapHtml = `<div style="color: var(--body-text);">`
    mapHtml += `x-mapped: ${gMapper.map(o.type,o.x).toFixed(5)}<br>`;
    mapHtml += `y-mapped: ${gMapper.map(o.type,o.y).toFixed(5)}<br>`;
    mapHtml += `(rho,theta): (${rho.toFixed(5)}, ${theta.toFixed(5)})`;
    mapHtml += "</div>"
    wsInfo.innerHTML=wsInfo.innerHTML+mapHtml;

    gm=gMapper.map;
    if(o.number==0 && o.value==1) {
      theta = gm(o.type,o.x);
    }
  }

  if(o.type=="joystick.button" && o.number==4 && o.value==1 ){
    cssModel.getNext();
  }
  if(o.type=="joystick.button" && o.number==6 && o.value==1 ){
    cssModel.getPrev();
  }

  wsInfo.innerHTML=wsInfo.innerHTML+
    `<div style="color:${cssModel.getCur().value}">
     ${cssModel.getCur().key}: ${cssModel.getCur().value}</div>`;
};


/*
https://stackoverflow.com/a/56250392

Example parsing
:root {
    --foo: #fff;
    --bar: #aaa
}
*/
const cssRootVars = [].slice.call( document.styleSheets )
    .map( styleSheet => [].slice.call(styleSheet.cssRules) )
    .flat()
    .filter( cssRule => cssRule.selectorText === ':root' )
    .map( cssRule => cssRule.
                     cssText.split( '{')[1].split('}')[0].trim().split(';'))
    .flat()
    .filter(text => text !== "")
    .map( text => text.split(':') )
    .map( parts => ( { key: parts[0].trim(), value: parts[1].trim() } ) );
/*
// Second way to parse.
// Good example of map/reduce efficiencies.
var allCSS = [].slice.call(document.styleSheets)
  .reduce(function(prev, styleSheet) {
    if (styleSheet.cssRules) {
      return prev + [].slice.call(styleSheet.cssRules)
        .reduce(function(prev, cssRule) {
          if (cssRule.selectorText == ':root') {
            var css = cssRule.cssText.split('{');
            css = css[1].replace('}','').split(';');
            for (var i = 0; i < css.length; i++) {
              var prop = css[i].split(':');
              if (prop.length == 2 && prop[0].indexOf('--') == 1) {
                console.log('Property name: ', prop[0]);
                console.log('Property value:', prop[1]);
              }
            }
          }
        }, '');
    }
  }, '');
*/

function CssModel(keyVals=[]){
   var cssVars=[];
   var curVarIndex=0;

   cssVars =  keyVals;

   var publicInterface = {
      add: function(key,value) {
          cssVars.push({"key":key,"value":value});
      },
      getAll: function () { return cssVars; },
      getCur: function () { return cssVars[curVarIndex]; },
      getNext: function (){
          curVarIndex= ++curVarIndex % cssVars.length;
          return cssVars[curVarIndex];

      },
      getPrev: function (){
          if(curVarIndex <= 0) curVarIndex=cssVars.length;
          curVarIndex= --curVarIndex % cssVars.length;
          return cssVars[curVarIndex];
      }
   }
   return publicInterface;
}


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

cssModel=CssModel(cssRootVars);
//cssModel.add("testKey1","testVal1");
//cssModel.add("testKey2","testVal2");
//cssModel.add("testKey3","testVal3");

gMapper=Mapper();
gMapper.add("joystick.axis",function(v){ return v / parseFloat(32767)});

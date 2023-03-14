// Handle controls and drawing a new frame

function handleFrame(timestamp) {

    let gamepad = navigator.getGamepads()[0];

    //handleInput(gamepad); // Exercise for the reader

    let data = { buttons:[]};
    gamepad?.buttons?.forEach( x=> { data.buttons.push(x.pressed)});

    if(data.buttons[0] === true) {
         let ci = document.querySelector("chapter-indicator");
         if (ci.style.borderColor == "blue"){
             ci.style.borderColor="red";
          }
         else{
             ci.style.borderColor="blue";
         } 
    }
    data.axes = gamepad?.axes;
    let json = JSON.stringify(data, null, 4);
  
   
    //drawScene(); // Exercise for the reader
    gaiaGlobals.realtimeModalBody.innerHTML=`<pre>${json}</pre>`;
    
    // Render it again, Sam
    requestAnimationFrame(handleFrame);
}

window.addEventListener("DOMContentLoaded", function () {
  gaiaGlobals.realtimeModalBody = document.querySelector(
   "#modal-realtime .modal-body");

  // Kick off the rendering
  requestAnimationFrame(handleFrame);
});



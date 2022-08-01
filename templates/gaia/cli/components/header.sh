#/bin/bash
cat <<'EOF'
<header
style="
  position:fixed;
  top: 0;
  left: 0;
  color: var(--h1-color);
  background: #1e1e1e;
  height:4rem;
  width: 100%;
  margin: 0;
  padding: 0;
  overflow:hidden;
  display:flex;
  flex-direction:column;
  font-size:1.5rem;
  justify-content:top; /* main axis is up and down */
  align-items:center; /* off axis is left/right */
} 
">
<chapter-indicator>
EOF

chapters=("Chapter 0" \
"Introduction " \
 "Taking a leap into the deeply personal" \
"First Impressions" \
"Seeing the prompts in one word" \
"Using words to step away from words" \
"What do we want?" \
"Investigating personal identity" \
"Being and doing" \
"Natural limits" \
"Self-regulating systems and individual choice" \
"Contemplation" \
)

for c in  $(seq 1 11)
do
    title="${chapters[c]}"
    printf "  <div slot='title' data-target='c$c'>$title</div>\n"
done

cat <<'EOF'
</chapter-indicator>
<script>
class ChapterIndicator extends HTMLElement {
    constructor() {
        super();
        this.attachShadow({mode: 'open'});                                      
        this.template = document.createElement('template');
        this.template.innerHTML = `
<style>
:host {
  display:flex;
  flex-direction: column;   /* main axis is verticle (up and down) */
  justify-content: center; /* main axis: direction=column -> up/down */
  align-items: center; /* cross axis: left/right */
  border: 1px solid red;
}


::slotted(*) {
  text-align:center;
  width:100%;
  display:none;
}

::slotted(.active){
  display:block;
}

</style>
<slot name="title">chapter missing</slot>
`;
       this.shadowRoot.appendChild(this.template.content.cloneNode(true));

   } //end of constructor

    connectedCallback() {
        //this.innerHTML="What up!"  // Not on shadowDom, won't show up! 
    }

    init(){
    }
} // end of class defintion of WebComponent: WaveMachine extends HTMLElement


customElements.define('chapter-indicator', ChapterIndicator);

</script>
</header>
EOF

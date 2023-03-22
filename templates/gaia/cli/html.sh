#!/bin/bash
##################################################################
# HTML Formatting
# This function creates the entire HTML page.
###################################################################

#  https://unix.stackexchange.com/a/24955
gaia-html-watch-components(){
  while inotifywait -e close_write ./components;\
  do gaia-html-update-style; done
}

gaia-html-update-style(){
  echo "Building version: $GAIA_VERSION"
  gaia-html-make-components
  gaia-html-make-head
  gaia-html-make-header
  gaia-html-make-footer
  gaia-html-cat-all > "./$GAIA_VERSION.html"
}

gaia-html-make-all(){
  pre=${1:-$pre}
  echo "Building $GAIA_VERSION pre $pre"
  gaia-html-make-components
  gaia-html-make-head
  gaia-html-make-header
  gaia-html-make-body  # calls make-chapter
  gaia-html-make-footer
  gaia-html-cat-all > "./${GAIA_VERSION}pre$pre.html"
  ((pre++))
  export BUILD_STRING="./${GAIA_VERSION}pre$pre -- $(date)"
}

gaia-html-cat-all(){
  local dir=$GAIA_HTML
  cat "$dir/head.html" 
  cat "$dir/joystick.html"
  cat "$dir/header.html" 
  cat "$dir/body.html"
  cat "$dir/footer.html"
}

#  take an integer and returns the string at index 
#  modulo len(colors)
gaia-html-get-color(){
  local colors=(orange red)
  local  ci=$(($1 % ${#colors[@]}))
  local color=${colors[$ci]}
  echo $color;
}

# create array of two class names. $1 would typically 
# be set by an outer loop over the sentences.
gaia-html-get-alternating-sentence-class(){
  local classes=("sentence" "sentence-alt")
  local  i=$(($1 % ${#classes[@]}))
  local class=${classes[$i]}
  echo $class;
}

# Document Schema
#
# Header
# Title
# Chapter contains par and sections
#  paragraph
#  paragraph
#  Section one of Prompt, Author
#    para
#
# First line is chapter title
# Each line thereafter is either a paragraph or a prompt.
gaia-html-make-chapter(){
  local chapterLines=$(gaia-get-chapter-lines $1)
  echo "$chapterLines" > debug.txt
  #readarray lineArray <<<  $chapterLines
  lineArray=()
  while IFS=$'\n' read -r line; do
    lineArray+=("$line")
  done <<< "$chapterLines"
 
  gaia-html-make-chapter-title "${lineArray[0]}"
  unset 'lineArray[0]'  # first line was chapter heading
  local promptRegex="^P[0-9]+:"

  # each line is either an 
  #  1) unstructured paragraph (after chapter heading)
  #  2) prompt section
 
  local paragraphIndex=0
  local promptIndex=0

  # Each line in Chapter is paragraph, prompt or author 
  for i in ${!lineArray[@]}; do 
    local curLine=${lineArray[$i]}

    #if it's not a prompt section
    if [[ ! $curLine =~  $promptRegex ]]; then 

      printf "\n\n<p id='c$1-par$i'>"
      ((paragraphIndex++))
      sentLines="$(gaia-str-to-sentences "$curLine")"
      #readarray sentArray <<< $sentLines
      sentArray=()
      while IFS=$'\n' read line; do
        sentArray+=("$line")
      done <<< "$sentLines"

      for j in ${!sentArray[@]}; do
        sent=${sentArray[$j]};
        gaia-html-make-sentence \
          "$sent" $(gaia-html-get-alternating-sentence-class $j)
      done

      printf "\n</p>"  

    fi

    if [[ $curLine =~  $promptRegex ]]; then 
        gaia-html-make-prompt "$curLine" "c$1-p$promptIndex"
        ((promptIndex++))
    fi 
  done
  echo "</section>"
}

gaia-html-make-prompt(){
  printf "\n<h3 id='$2'>\n$1\n</h3>"
  #printf "\n<h3 id='$2'>\n$(echo $1 | fmt -65)\n</h3>"
}
gaia-html-make-sentence(){
  printf "\n<span class='$2'>\n$1\n</span>"
  #printf "\n<span class='$2'>\n$(echo $1 | fmt -65)\n</span>"
}
      sentArray=()
gaia-html-make-span(){
  printf "\n<span style='color:$2'>\n$1\n</span>"
  #printf "\n<span style='color:$2'>\n$(echo $1 | fmt -65)\n</span>"
}

# COMPOSE HTML
# export local JOYSTICK_HTML=$(cat $GAIA_HTML/joystick.html)
gaia-html-make-head() {
  local file="$GAIA_HTML/head.html"
  cat "$GAIA_COMPONENTS/head.env" | envsubst > $file 


  echo "<style>" >> $file
  cat $GAIA_COMPONENTS/style.css >> $file
  cat $GAIA_COMPONENTS/modal.css >> $file
  echo "</style>" >> $file
  echo "</head>" >> $file
  echo "<script>"  >> $file
  echo "gaiaGlobals = {};" >> $file
  cat $GAIA_COMPONENTS/*.js >> $file
  echo "</script>" >> $file
}

gaia-html-make-header(){
  local file="$GAIA_HTML/header.html"
  $GAIA_COMPONENTS/header.sh  > $file 
}

gaia-html-make-body(){
  local bodyfile="$GAIA_HTML/body.html"
  printf "<body>\n<h1>Knowing Gaia</h1>\n" > $bodyfile
  gaia-html-make-chapter 1 >> $bodyfile
  gaia-html-make-chapter 2 >> $bodyfile
  gaia-html-make-chapter 3 >> $bodyfile
  gaia-html-make-chapter 4 >> $bodyfile
  gaia-html-make-chapter 5 >> $bodyfile
  gaia-html-make-chapter 6 >> $bodyfile
  gaia-html-make-chapter 7 >> $bodyfile
  gaia-html-make-chapter 8 >> $bodyfile
  gaia-html-make-chapter 9 >> $bodyfile
  gaia-html-make-chapter 10 >> $bodyfile
  gaia-html-make-chapter 11 >> $bodyfile
}

gaia-html-make-footer(){
  local file="$GAIA_HTML/footer.html"
  export NAV_HTML="$(gaia-html-make-nav)";
  cat "$GAIA_COMPONENTS/footer.env" | envsubst > $file
}

gaia-html-make-zen-circle(){
  dataStr=$(base64 $GAIA_ASSETS/zen-circle-mod.png)
  export local imgSrcStr="data:image/png;charset=utf-8;base64,  $dataStr"
  cat <<EOF
<img class="zen-circle"                                                         
src="$imgSrcStr"                                                                
alt="zen-circle">                                                               
<br>                                                                            
<a id="email"                                                                   
  href="mailto:patadducci1940@gmail.com">patadducci1940@gmail.com</a>           
EOF
}

# Assumes title string is "C3: Third chapter title"
# Grab the chapter number and the title text with awk.
gaia-html-make-chapter-title(){
  local title="$1"
  local number=$(echo $title | awk -F[C:] '{print $2}')
  local text=$(echo $title | awk -F[:] '{print $2}')
  printf "\n<section id='c$number'>\n"
  printf "<h2>Ch %s. ~ %s</h2>" "$number" "$text"
}

gaia-html-make-chapter-indicator() {
echo "<chapter-indicator>"
  for c in  $(seq 1 11)
    do
      
        local chapterLines=$(gaia-get-chapter-lines $1)
        #readarray lineArray <<<  $chapterLines

        lineArray=()
        while IFS=$'\n' read line; do
          lineArray+=("$line")
        done <<< "$chapterLines"

        local title="${lineArray[0]}"
      printf "  <div slot='title' data-target='c$c'>$title</div>\n"
  done
echo "<chapter-indicator>"

}
# helper function to create html
gaia-html-make-nav(){
  echo "<nav id=\"chapterNav\">"
  for c in  $(seq 1 11)
    do
      printf "  <div data-target='c$c'>$c</div>\n"
  done
  echo "</nav>"
  cat <<EOF
<script>
window.addEventListener('DOMContentLoaded', (event) => {
    console.log('DOM fully loaded and parsed');
    let nav=document.querySelector("#chapterNav");
    let header=document.querySelector("header");
    for (var i=0; i< nav.children.length; i++){
        nav.children[i].addEventListener("click",handleChapterNav);
    }

    //https://css-tricks.com/almanac/selectors/a/attribute/
    navSpy = new ScrollControl();
    chapterSpy = new ScrollControl({indicatorSelector:"chapter-indicator"});


    window.onload = function () {
        navSpy.onScroll();
        chapterSpy.onScroll();
    };
    window.addEventListener('scroll', () => {
        navSpy.onScroll();
        chapterSpy.onScroll();
    });




    function handleChapterNav(evt){
        console.log(evt);
        let el=document.querySelector("#"+evt.target.dataset.target);
        var scrollOptions = {
                left: el.offsetLeft,
                top:el.offsetTop-header.clientHeight,
                behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }
});
</script>
EOF
}
gaia-html-make-components(){
   for component in $(ls -1 components/*.env)
   do
      local basename=$(basename $component)
      cat $component | envsubst > "html/${basename%.*}.html"
      echo "wrote to: html/${basename%.*}.html" >> $GAIA_DIR/gaia.log
   done 
}

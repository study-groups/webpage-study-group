#!/bin/bash
##################################################################
# HTML Formatting
# This function creates the entire HTML page.
###################################################################
gaia-html-make-all-old(){
  gaia-html-make-header
  gaia-html-make-body-old  # calls make-chapter
  gaia-html-make-footer
  gaia-html-cat-all > ./index-old.html
}
gaia-html-build(){
  echo "Building version: $GAIA_VERSION"
  gaia-components-to-html
  gaia-html-make-all > "./$GAIA_VERSION.html"
}

gaia-html-make-all(){
  gaia-html-make-header
  gaia-html-make-body  # calls make-chapter
  gaia-html-make-footer
  gaia-html-cat-all
}
gaia-html-cat-all(){
  local dir=$GAIA_HTML
  cat  "$dir/header.html" "$dir/body.html" "$dir/footer.html"
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
  echo "in gaia-html-make-chapter $1" >> build.log
  local chapterLines=$(gaia-get-chapter-lines $1)
  readarray lineArray <<<  $chapterLines
  gaia-html-make-chapter-title "${lineArray[0]}"
  unset 'lineArray[0]'  # first line was chapter heading
  local promptRegex="^P[0-9]+:"

  # each line is either an 
  #  1) unstructured paragraph (after chapter heading)
  #  2) prompt section
  #  3) Author info
 
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
      readarray sentArray <<< $sentLines

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
}

gaia-html-make-prompt(){
  printf "\n<h3 id='$2'>\n$1\n</h3>"
  #printf "\n<h3 id='$2'>\n$(echo $1 | fmt -65)\n</h3>"
}
gaia-html-make-sentence(){
  printf "\n<span class='$2'>\n$1\n</span>"
  #printf "\n<span class='$2'>\n$(echo $1 | fmt -65)\n</span>"
}
gaia-html-make-span(){
  printf "\n<span style='color:$2'>\n$1\n</span>"
  #printf "\n<span style='color:$2'>\n$(echo $1 | fmt -65)\n</span>"
}

# COMPOSE HTML
gaia-html-make-header() {
  export local NAV_HTML=$(cat $GAIA_HTML/nav.html)
  export local JOYSTICK_HTML=$(cat $GAIA_HTML/joystick.html)
  export local STYLE_CSS=$(cat $GAIA_HTML/style.css)
  cat "$GAIA_COMPONENTS/header.env" | envsubst > "$GAIA_HTML/header.html"
}

gaia-html-make-body(){
  local bodyfile="$GAIA_HTML/body.html"
  gaia-html-make-chapter 1 > $bodyfile
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
  export local FOOTER_JS=$(cat $GAIA_COMPONENTS/*.js)
  dataStr=$(base64 $GAIA_ASSETS/zen-circle-mod.png)
  export local imgSrcStr="data:image/png;charset=utf-8;base64,  $dataStr"
  cat "$GAIA_COMPONENTS/footer.env" | envsubst > "$GAIA_HTML/footer.html"
}

# Assumes title string is "C3: Third chapter title"
# Grab the chapter number and the title text with awk.
gaia-html-make-chapter-title(){
  local title="$1"
  local number=$(echo $title | awk -F[C:] '{print $2}')
  local text=$(echo $title | awk -F[:] '{print $2}')
  printf "<h2 id='c$number'>Ch %s. ~ %s</h2>" "$number" "$text"
}

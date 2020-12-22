#!/bin/bash
# shellcheck disable=SC2155
## shellcheck disable=SC2086 
# Dbl quote to prevent globbing and word splitting.
PS1="gaia> "
cat /dev/null > build.log
gaia-help(){
  cat <<EOF
This is a collection of Bash functions for Extraction,
Transformation and Loading of the Google document Knowing Gaia.

https://docs.google.com/document/d/1QCWu6BMxVjcee9mf7tEMx8Z048ciYwlmx-EkoVSyzVI


It is also a command line interface for reading the book.

1. Copy and paste text into raw.txt
2. gaia-clean
3. gaia-index
4. gaia-display 2 3 # display Chapter 2, Prompt 3

To make webpage:

5. gaia-make-html-all > index.html

EOF
}
gaia-extract(){
  echo "Paste entire raw text document then hit ctrl-D on new line."
  cat > ./raw.txt
}

gaia-clean(){
  ./clean  raw.txt | awk 'NF' > clean.txt
}

gaia-index(){
  ./indexer clean.txt > clean.index
}

gaia-make-notes(){
  gaia-notes-md > notes.md
}

gaia-reset(){
  rm clean.txt
  rm clean.index
  rm notes.md
}

gaia-get-between(){
  local start=$1;
  local end=$2;
  local file=${3:-clean.txt};
  < "$file" tail -n +"$1" | head -n "$(($2 - $1))"
}

gaia-get-unit-id(){
  local chapter=$1
  local prompt=$2
  #echo "Getting unit id for Chapter $chapter, Prompt $prompt"
  echo $(( 2 + chapter*11 + prompt))
}

gaia-get-offset(){
  local tokens=($(sed "$1q;d" ./clean.index))
  echo "${tokens[0]}" # quotes not necessary since its a token
}

#shellcheck disable=SC2086
gaia-get-unit-text(){
  local id=$1
  local idNext=$((id + 1))
  local offset=$(gaia-get-offset $id)
  local offsetNext=$(gaia-get-offset $idNext)
  gaia-get-between $((offset+1)) $offsetNext
}

#shellcheck disable=SC2086
gaia-get-chapter-offset(){
  local line=($(awk /"chapterStart C$1"/ ./clean.index))
  echo ${line[0]}
}

#shellcheck disable=SC2086
gaia-get-author-offset(){
  local line=($(awk /"authorStart"/ ./clean.index))
  echo ${line[0]}
}

#shellcheck disable=SC2086
gaia-get-document-end(){
  local line=($(awk /"documentEnd"/ ./clean.index))
  echo ${line[0]}
}

#shellcheck disable=SC2086
gaia-get-prompt(){
  local indexLine=($(awk /"promptStart P$1"/ ./clean.index))
  local promptIndex=${indexLine[0]}
  gaia-get-line $promptIndex
}

gaia-get-line(){
  sed "$1q;d" ./clean.txt
}

# Normally want to "" $variables. But when the variable
# is known to be single token, do not quote (ignore SC2046 warning) 
# shellcheck disable=SC2046,SC2086
gaia-display(){
  local chapter=$1 # single token number 
  local prompt=$2  # single token number
  local width=${3:-60}
  local unitId=$(gaia-get-unit-id $chapter $prompt)
  local chapterText="$(gaia-get-line $(gaia-get-chapter-offset $chapter))"
  local promptText="$(gaia-get-prompt $prompt)"
  local text=$(gaia-get-unit-text $unitId)
  local textFmt=$(echo -e "$chapterText\n\n$promptText\n\n$text" | 
                   fmt -$width | sed -e 's/^/         /')
  local len=$(echo -e "$textFmt" | wc -l );
  local margin=$(( (24-len)/2 ))
  clear;
  if (( len < 23 ))
  then 
    printf '\n%.0s' $(seq 1 $margin) 
    echo "$textFmt" 
    printf '\n%.0s' $(seq 1 $margin) 
  else
    echo "$textFmt" | less
    echo "$textFmt" 
  fi 
}

# Multiple sentences per line.
# Think 'one paragraph per line'.
gaia-str-to-sentences(){
  local str="$1"
  local lines=$(echo $str | sed 's/\. /\.\n/g')  # adds newlines
  echo "$lines"  # Glob to retain \n
}

gaia-get-chapter-lines(){
  local authorOffset=$(gaia-get-author-offset)
  local docEnd=$(gaia-get-document-end)
  local chapter=$1;
  local chapterPlus1=$((chapter + 1))
  local start=$(gaia-get-chapter-offset $chapter)
  local end=$(gaia-get-chapter-offset $chapterPlus1)
  [[ -z $end ]] && end=$authorOffset
  local chapterLines=$(gaia-get-between $start $end); # keeps new lines
  echo "$chapterLines" #Quote to preserve newlines
}

# Both $@ and $* expand to separate args and then wordsplit and globbed.
# Quoted, "$@" expands each element as a separate argument,
# while   "$*" expands to the args merged into one argument: 
# "$1c$2c..." (where c is the first char of IFS).

# In contrast to the otherwise 1) StackOverflow below,
# You should not expand "${arr[@]}" but instead use "${arr[*]}"
# as printable string as recommended by shellcheck. However,
# as 2) says, echo does not care if it is getting multiple
# arguments or not. The args are separated by the first
# char of the IFS, typical a space, so, end user of stdout
#can't tell either.
#
# 1) https://stackoverflow.com/a/15692004/4249785
# 2) https://stackoverflow.com/a/55149711/4249785
# https://www.gnu.org/software/bash/manual/html_node/Word-Splitting.html
# https://tldp.org/LDP/abs/html/globbingref.html
#
gaia-text-to-sentence-demo(){
  local text="$1"
  echo "Got input: $text"
  local sentenceLines=$(echo $text | sed 's/\. /\.\n/g')  # adds newlines
  echo "Got sentenceLines: $sentenceLines"
  echo "Got sentenceLines[*]: ${sentenceLines[*]}" # its a string, not an array
  echo "Got #sentenceLines[@]: ${#sentenceLines[@]}"# always one
  echo "Got #sentenceLines: ${#sentenceLines}" # 

  # Lines-to-Array method one. Looses \n.
  arr=(); 
  while IFS= read -r l; do arr+=("$l"); done <<< "$sentenceLines"
  echo "Got #arr[@]: ${#arr[@]}"
  echo "Got arr[*]: ${arr[*]}"

  # Lines-to-Array method two. Preserves \n.
  readarray arr2 <<< $sentenceLines
  echo "Got #arr2[@]: ${#arr2[@]}"
  echo "Got arr2[*]: ${arr2[*]}"
}


##################################################################
# HTML Formatting
# This function creates the entire HTML page.
###################################################################
gaia-make-html-all(){
  gaia-make-html-header
  gaia-make-html-body
  gaia-make-html-footer
}

gaia-get-color(){
  local colors=(orange red)
  local  ci=$(($1 % ${#colors[@]}))
  local color=${colors[$ci]}
  echo $color;
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
gaia-make-html-chapter(){
  echo "in gaia-make-html-chapter $1" >> build.log
  local chapterLines=$(gaia-get-chapter-lines $1)
  readarray lineArray <<<  $chapterLines
  gaia-make-html-chapter-title "${lineArray[0]}"
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
        gaia-make-html-span "$sent" $(gaia-get-color $j)
      done
      printf "\n</p>"  

    fi

    if [[ $curLine =~  $promptRegex ]]; then 
        gaia-make-html-prompt "$curLine" "c$1-p$promptIndex"
        ((promptIndex++))
    fi 
  done
}

gaia-make-html-prompt(){
  printf "\n<h3 id='$2'>\n$1</h3>"
}
gaia-make-html-span(){
  printf "\n<span style='color:$2'>\n$1</span>"
}

#shellcheck disable=SC2046,SC2086
gaia-make-html-body(){
  gaia-make-html-chapter 1
  gaia-make-html-chapter 2
  gaia-make-html-chapter 3
  gaia-make-html-chapter 4 
  gaia-make-html-chapter 5 
  gaia-make-html-chapter 6  
  gaia-make-html-chapter 7
  gaia-make-html-chapter 8
  gaia-make-html-chapter 9
  gaia-make-html-chapter 10
  gaia-make-html-chapter 11
}

gaia-make-html-chapters-old(){

 for c in  3 4 5 6 7 8 9 10 11
  do
    local chapterName=$(gaia-get-line $(gaia-get-chapter-offset $c))
    gaia-make-chapter-html "$chapterName"
    for p in 1 2 3 4 5 6 7 8 9 10
    do
      local unitId=$(gaia-get-unit-id $c $p)
      local promptText=$(gaia-get-prompt $p)
      local text="$(gaia-get-unit-text $unitId)"
      local modPromptText="P$p ~ ${promptText:3}"
      gaia-make-unit-html "$modPromptText" "$text"
    done # prompt loop

  done # chapter loop
}

# NAV_HTML
gaia-make-html-header() {
  export local NAV_HTML=$(gaia-make-html-nav)
  cat ./header.html | envsubst
}

gaia-make-html-nav(){
  cat<<EOF
<ul>
<li onclick='ScrollTo("c1")'>c1</li>
<li onclick='ScrollTo("c2")'>c2</li>
<li onclick='ScrollTo("c3")'>c3</li>
<li onclick='ScrollTo("c11")'>c11</li>
</ul>
<script>
// https://stackoverflow.com/a/36929383/4249785
function ScrollTo(name) {
  ScrollToResolver(document.getElementById(name));
}

function ScrollToResolver(elem) {
  var navbar=document.getElementById("navbar");
  var navHeight=parseInt(navbar.getBoundingClientRect().height);
  if(!navHeight) navHeight=0;

  console.log("navHeight",navHeight);
  var jump = parseInt((elem.getBoundingClientRect().top-navHeight) * .2);
  document.body.scrollTop += jump;
  document.documentElement.scrollTop += jump;
  if (!elem.lastjump || elem.lastjump > Math.abs(jump)) {
    elem.lastjump = Math.abs(jump);
    setTimeout(function() { ScrollToResolver(elem);}, "40");
  } else {
    elem.lastjump = null;
  }
}
</script>
EOF
}
gaia-make-html-footer(){
  cat <<EOF
<img class="zen-circle" 
src="./assets/zen-circle-mod.png" 
alt="zen-circle">
<br>
<section class="author-container">
<ul class="author">
  <li aria-label="author's name">Pat Adducci</li>
  <li>Yucca Valley, California</li>
  <br>
  <li>May 15, 2020</li>
</ul>
</section>
<a id="email" 
  href="mailto:patadducci1940@gmail.com">patadducci1940@gmail.com</a>
</main>
<footer>
</footer>
</body>
</html>

</html>
EOF
}

gaia-make-html-chapter-title(){
  local title="$1"
  local number=$(echo $title | awk -F[C:] '{print $2}')
  local text=$(echo $title | awk -F[:] '{print $2}')
  printf "<h2 id='c$number'>Ch %s. ~ %s</h2>" "$number" "$text"
}


gaia-make-unit-html(){
  local promptText="$1"
  local text="$2"
  cat <<EOF
<h3>$promptText</h3>
<div class="unit">
<p>$text
</p>
</div>
EOF
}

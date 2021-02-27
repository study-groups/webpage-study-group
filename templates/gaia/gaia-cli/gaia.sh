#!/bin/bash
# shellcheck disable=SC2155
## shellcheck disable=SC2086 
# Dbl quote to prevent globbing and word splitting.
PS1="gaia> "
GAIA_HTML="$PWD/html" # set when sourced

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

gaia-reset(){
  rm clean.txt
  rm clean.index
}

# get lines from $1 to $2 in file $3, $3=clean.txt by default.
# consider rewriting with single awk cal
gaia-get-between(){
  local start=$1;
  local end=$2;
  local file=${3:-clean.txt};
  < "$file" tail -n +"$1" | head -n "$(($2 - $1))"
}

# Convert from two dim (chapter,prompt) to one dim (unitID).
# Examples: (1,2) => 15; (2,2) => 26.
gaia-get-unit-id(){
  local chapter=$1
  local prompt=$2
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

##################################################################
# HTML Formatting
# This function creates the entire HTML page.
###################################################################
gaia-make-html-all(){
  gaia-make-html-header
  gaia-make-html-body
  gaia-make-html-footer
}

#  take an integer and returns the string at index 
#  modulo len(colors)
gaia-get-color(){
  local colors=(orange red)
  local  ci=$(($1 % ${#colors[@]}))
  local color=${colors[$ci]}
  echo $color;
}

# create array of two class names. $1 would typically 
# be set by an outer loop over the sentences.
gaia-get-alternating-sentence-class(){
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
        #gaia-make-html-span "$sent" $(gaia-get-color $j)
        gaia-make-html-sentence \
          "$sent" $(gaia-get-alternating-sentence-class $j)
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
gaia-make-html-sentence(){
  printf "\n<span class='$2'>\n$1</span>"
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

# NAV_HTML
gaia-make-html-header() {
  #export local NAV_HTML=$(gaia-make-html-nav)
  export local NAV_HTML=$(cat $GAIA_HTML/nav.html)
  export local STYLE_CSS=$(cat $GAIA_HTML/style.css)
  cat "$GAIA_HTML/header.html.env" | envsubst
}

gaia-make-html-footer(){
  cat "$GAIA_HTML/footer.html"
}

# Assumes title string is "C3: Third chapter title"
# Grab the chapter number and the title text with awk.
gaia-make-html-chapter-title(){
  local title="$1"
  local number=$(echo $title | awk -F[C:] '{print $2}')
  local text=$(echo $title | awk -F[:] '{print $2}')
  printf "<h2 id='c$number'>Ch %s. ~ %s</h2>" "$number" "$text"
}

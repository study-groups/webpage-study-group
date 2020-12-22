#!/bin/bash
# shellcheck disable=SC2155
# Dbl quote to prevent globbing and word splitting.
# shellcheck disable=SC2086 
PS1="gaia> "
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
  < $file tail -n +"$1" | head -n "$(($2 - $1))"
}

gaia-get-unit-id(){
  local chapter=$1
  local prompt=$2
  #echo "Getting unit id for Chapter $chapter, Prompt $prompt"
  echo $(( 2 + chapter*11 + prompt))
}

gaia-get-offset(){
  local tokens=($(sed "$1q;d" ./clean.index))
  echo ${tokens[0]} 
}

gaia-get-unit-text(){
  local id=$1
  local idNext=$((id + 1))
  local offset=$(gaia-get-offset $id)
  local offsetNext=$(gaia-get-offset $idNext)
  gaia-get-between $((offset+1)) $offsetNext
}

gaia-get-chapter-offset(){
  line=($(awk /"chapterStart C$1"/ ./clean.index))
  echo ${line[0]}
}

gaia-get-prompt(){
  indexLine=($(awk /"promptStart P$1"/ ./clean.index))
  local promptIndex=${indexLine[0]}
  gaia-get-line $promptIndex
}

gaia-get-line(){
  sed "$1q;d" ./clean.txt
}

gaia-display(){
  local chapter=$1
  local prompt=$2
  local width=${3:-60}
  local unitId=$(gaia-get-unit-id $chapter $prompt)
  local chapterText=$(gaia-get-line $(gaia-get-chapter-offset $chapter))
  local promptText=$(gaia-get-prompt $prompt)
  local text=$(gaia-get-unit-text $unitId)
  local textFmt=$(echo -e "$chapterText\n\n$promptText\n\n$text" | 
                   fmt -$width | sed -e 's/^/         /')
  local len=$(echo -e "$textFmt" | wc -l );
  local margin=$(( (24-len)/2 ))
  clear;
  if [[ $len < 23 ]]
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
  lines=$(echo $str | sed 's/\. /\.\n/g')  # adds newlines
  echo "$lines"  # Glob to retain \n
}

# Example for quoting rules.
gaia-str-to-array-demo(){
  local str="$1"
  echo "Got input: $1"
  lines=$(echo $str | sed 's/\. /\.\n/g')  # adds newlines
  echo "Got lines: $lines"
  echo "Got lines[@]: ${lines[@]}"
  echo "Got #lines[@]: ${#lines[@]}"

  readarray arr <<<  $(echo "$lines");

  echo "arr is ${arr[1]}"
  echo "Got arr $arr"
  echo "Got arr[@]: ${arr[@]}"
  echo "Got #arr[@]: ${#arr[@]}"
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

gaia-make-html-body(){
  local start=$(gaia-get-chapter-offset 1)
  local end=$(gaia-get-chapter-offset 2)
  local chapterLines=$(gaia-get-between $start $end); # keeps new lines
  local chapterName=$(gaia-get-line $(gaia-get-chapter-offset 1))
  local modChapName="Ch. 1  ~ ${chapterName:3}"
  gaia-make-chapter-html "$modChapName"
 
  while IFS= read -r line; do
    local lineArray+=("$line") # glob line together as single array element
  done <<< "$chapterLines"

 for i in "${!lineArray[@]}"; do # glob line or else get words
    if (( i > 0 )) 
    then
      while IFS= read -r curLine; do
        local sentLines=$(gaia-str-to-sentences "$curLine")
      done <<< "${lineArray[$i]}"

      local sentArray=();
      while IFS= read -r line;  do sentArray+=($line); done <<< "$sentLines"

      for j in ${!sentArray}; do
        echo "<p>I=$i J=$j sentArray is ${sentArray[$j]}</p>"  
      done
    fi
 done


 for c in  3 4 5 6 7 
  do
    local chapterName=$(gaia-get-line $(gaia-get-chapter-offset $c))
    local modChapName="Ch. $c ~ ${chapterName:3}"
    gaia-make-chapter-html "$modChapName"

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

gaia-make-html-css(){
  gaia-get-between 38 130 ../gaia-index.html
}

gaia-make-html-header(){
  local style="$(gaia-make-html-css)";
  cat <<EOF
<html>
<head>
$style
</head>
<h1 class="main-header" >Knowing Gaia</h1>
EOF
}

gaia-make-html-footer(){
  cat <<EOF
</html>
EOF
}

gaia-make-chapter-html(){
  local chapterTitle=$1
  echo "<h2>$chapterTitle</h2>"
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

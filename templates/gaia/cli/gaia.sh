#!/bin/bash
# shellcheck disable=SC2155
# shellcheck disable=SC2086
GAIA_DIR=$PWD                          # source ./gaia.sh
GAIA_HTML="$GAIA_DIR/html"             # set when sourced
GAIA_COMPONENTS="$GAIA_DIR/components" # set when sourced
export GAIA_VERSION="Version not set. Edit-gaia.sh."
GAIA_VERSION="005"
export GAIA_ASSETS="$GAIA_DIR/../assets"
source html.sh

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
1. Set bash variable GAIA_VERSION
2. gaia-html-make-components   # takes ./components -> ./html
3. gaia-html-make-all > \$GAIA_VERSION.html 

EOF
}

gaia-extract(){
  echo "Paste entire raw text document then hit ctrl-D on new line."
  cat > ./raw.txt
}

gaia-clean(){
  ./clean raw.txt  > clean.txt
}

gaia-index(){
   cat clean.txt | ./index > clean.index
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

gaia-get-unit-text(){
  local id=$1
  local idNext=$((id + 1))
  local offset=$(gaia-get-offset $id)
  local offsetNext=$(gaia-get-offset $idNext)
  gaia-get-between $((offset+1)) $offsetNext
}

gaia-get-chapter-offset(){
  local line=($(awk /"chapterStart C$1"/ ./clean.index))
  echo ${line[0]}
}

gaia-get-author-offset(){
  local line=($(awk /"authorStart"/ ./clean.index))
  echo ${line[0]}
}

gaia-get-document-end(){
  local line=($(awk /"documentEnd"/ ./clean.index))
  echo ${line[0]}
}

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

gaia-docs(){
cat <<EOF

# Gaia Documentation System

## Overview

Gaia translates a raw text into HTML with id tags:

- Sentence: c2-s3-p2-s2 (chapter 2, section 3, paragraph 2, sentence 2)
- Paragraph: c2-s3-p2  
- Section: c2-s3
- Chapter: c2

Prompt sections are a special type of section.

## Architecture

### Client code

- ScrollControl: non-visual class for watching DOM scroll and updates via
simple publish-subrcibe method.

- ChapterIndicatorComponent web component: set by ScrollControl, uses slotted 
templates for chapter headings.

- NavComponent: web component for simple navigation bar used in the footer.
- ChapterComponent: web component with slots for <section-component>.
- SectionComponent: web component with slots for <p>.

### Server build code

Copy your text into raw.txt, see example of tags Gaia discovers in
the inital text asset.

```bash
source gaia.sh
gaia-clean  # transform raw.txt -> clean.txt 
gaia-index  # creates clean.index mapping elements to lines
gaia-display 2 3 # displays Ch. 2, Sec. 3 formated for terminal
```

EOF
}

gaia-help(){
  cat <<EOF
This is a collection of Bash functions for Extraction,
Transformation and Loading of the Google document Knowing Gaia.

It is also a command line interface for reading the book.

1. Copy and paste text into raw.txt
2. gaia-clean
3. gaia-index
4. gaia-display 2 3 # display Chapter 2, Prompt 3
EOF
}
gaia-extract(){
  echo "Paste entire raw text document then hit ctrl-D on new line."
  cat > ./data.txt
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
  local file=clean.txt;
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
  echo $(gaia-get-line $promptIndex)
}

gaia-get-line(){
  sed "$1q;d" ./clean.txt
}

gaia-display(){
  local chapter=$1
  local prompt=$2
  local unitId=$(gaia-get-unit-id $chapter $prompt)
  local chapterText=$(gaia-get-line $(gaia-get-chapter-offset $chapter))
  local promptText=$(gaia-get-prompt $prompt)
  local text=$(gaia-get-unit-text $unitId)
  local textFmt=$(echo -e "$chapterText\n\n$promptText\n\n$text" | 
                   fmt -60 | sed -e 's/^/         /')
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

gaia-notes-md(){
echo '
# Knowing Gaia Dev Note

## Original source
- https://docs.google.com/document/d/1QCWu6BMxVjcee9mf7tEMx8Z048ciYwlmx-EkoVSyzVI

## ETL: Extract Transform Load
### Extract
- Use Docs to Markdown Add-on in Google Doc
- paste into raw.html

### Transform
- `gaia-clean` transforms quote marks, etc
- `gaia-transform` creates long form webpage

### Load
- `gaia-index` creates data.index
- `gaia-display 3 5` displays Chapter 3, prompt 2.

## References
- markserv ./ -a 0.0.0.0 -p 8000  # serve ./, accept port 8000 on all interfaces
'
}

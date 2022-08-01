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

# Old, not used. A unit is the text associated with a
# chapter+prompt pair.  
# Worked with gaia-make-html-chapters-old()
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

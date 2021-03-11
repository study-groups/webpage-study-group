# Component to be added via envsubst nav.html.env file.
export NAV_CHAPTERS

# helper function to create html
nav-html-chapters(){
  for c in  $(seq 1 11)
    do
      printf "<li>$c</li>\n"
  done
}

# larger composite function will use NAV_HTML content
NAV_CHAPTERS="$(nav-html-chapters)"

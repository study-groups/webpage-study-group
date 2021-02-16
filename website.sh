website-help(){
cat <<EOF
website.sh is a collection of Bash scripts for:
1. simple web server based on python3
2. build manager  
EOF
}

website-build(){
  local ver=$1
  echo "Add buiild info."
}

website-server(){
  python3 -m http.server ${1:-8000} &
}

website-list() {
  ps -ef | grep [h]ttp.server
}

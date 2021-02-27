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

website-server-start(){
  python3 -m http.server ${1:-8000} &
}

website-server-list() {
  ps -ef | grep [h]ttp.server
}

website-clear-chrome(){
  cat << EOF
Go to chrome://net-internals/#hsts
Enter domain name in "Delete domain security policies"
EOF
}

cat << EOF
Website Study Group Todos

mv gaia to 005-gaia
add 005-gaia/001

mkdir assets
mv sg-logo assets

mkdir production
ln  -s ../dev/001-simple/003 production/study-groups
Considder rename simple to basic?

rm styleguide.html
ln -s dev/001-styleguide/003 dev/styleguild-current

mv favicon.ico to assets/

EOF

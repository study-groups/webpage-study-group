# builds a file named 005pre$1.html and copies it 
# into builds directory. This repo contains builds
# that are server independent and can be served
# from anywhere.

# e.g. $>b 1
# creates 005pre1.html

b(){
  source ./gaia.sh
  gaia-html-make-all $1 # adds pre$1 to major version
  cp ./005pre$1.html ../../../builds/gaia/005
}

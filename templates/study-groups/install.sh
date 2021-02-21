VER=001pre4
BUILD=$(realpath ../../builds/study-groups)

webpage-install(){
  rsync ./index.html $BUILD/$VER/
  rsync ./styleguide.html $BUILD/$VER/
  rsync ./error.html $BUILD/$VER/
  ln -f -s $BUILD/assets $BUILD/$VER/assets
  #git subtree push --prefix build/001 origin gh-pages  
}

webpage-remove(){
  echo rm -r $BUILD/$VER
}

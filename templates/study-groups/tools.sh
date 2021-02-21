VER=001pre4
BUILD=$(realpath ../../builds/study-groups)

tools-build(){
  rsync ./index.html $BUILD/$VER/
  rsync ./styleguide.html $BUILD/$VER/
  rsync ./error.html $BUILD/$VER/
  ln -f -s $BUILD/assets $BUILD/$VER/assets
}

tools-publish(){
  git subtree push --prefix builds/$VER origin gh-pages  
}

tools-clean(){
  echo rm -r $BUILD/$VER
}

VER=001pre4
BUILD=$(realpath ../../builds/study-groups)

install-webpage(){
  rsync ./index.html $BUILD/$VER/
  rsync ./styleguide.html $BUILD/$VER/
  rsync ./error.html $BUILD/$VER/
  ln -f -s $BUILD/assets $BUILD/$VER/assets
  #rsync ./assets $BUILD/
  
  #git subtree push --prefix build/001 origin gh-pages  
}

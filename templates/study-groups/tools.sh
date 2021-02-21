VER=001
BUILD=$(realpath ../../builds/study-groups)

tools-build(){
  rsync ./index.html $BUILD/$VER/
  rsync ./styleguide.html $BUILD/$VER/
  rsync ./error.html $BUILD/$VER/
  ln -f -s $BUILD/assets $BUILD/$VER/assets
}

tools-list-build(){
  ls -l $BUILD/$VER 
}
tools-publish(){
  git add $BUILD/$VER && git commit -m "Initial subtree commit."
  git subtree push --prefix $BUILD/$VER origin gh-pages  
}

tools-clean(){
  echo rm -r $BUILD/$VER
}

VER=001
BUILD=$(realpath ../../builds/study-groups)

tools-build(){
  rsync ./index.html $BUILD/$VER/
  rsync ./styleguide.html $BUILD/$VER/
  rsync ./error.html $BUILD/$VER/
  cp -r ./assets $BUILD/$VER/assets
  #ln -f -s $BUILD/assets $BUILD/$VER/assets
}

tools-list-build(){
  ls -l $BUILD/$VER 
}
tools-publish(){
  echo: git add $BUILD/$VER && git commit -m "Initial subtree commit."
  #echo: git subtree push --prefix $BUILD/$VER origin gh-pages  
  echo: git push origin `git subtree split --prefix build_folder master`:gh-pages --force
  git add $BUILD/$VER && git commit -m "Initial subtree commit."
  # git subtree push --prefix $BUILD/$VER origin gh-pages  
  git push origin `git subtree split --prefix $BUILD/$VER main`:gh-pages --force
}

tools-clean(){
  echo executing: rm -r $BUILD/$VER
  rm -r $BUILD/$VER
}

tools-show-nginx(){

  cat /etc/nginx/sites-enabled/study-groups.org
}

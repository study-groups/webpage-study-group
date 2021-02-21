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
  local tmpdir=/tmp/$(date +%s)
  mkdir $tmpdir
  git checkout main
  echo: cp -r $BUILD/$VER/ /$tmpdir 
  cp -r $BUILD/$VER/ /$tmpdir 
  git checkout gh-pages 
  git rm -r *
  cp -r $tmpdir/* . 
  git add .
  git commit -m"Publishing version $VER."
  git push origin gh-pages
  git checkout main 
  rm -rf $tmpdir
}

tools-clean(){
  echo executing: rm -r $BUILD/$VER
  rm -r $BUILD/$VER
}

tools-show-nginx(){

  cat /etc/nginx/sites-enabled/study-groups.org
}

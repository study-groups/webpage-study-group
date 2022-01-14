REPO=$(realpath "/home/$USER/src/webpage-study-group")
TEMPLATE=$(realpath $REPO/templates/study-groups)
BUILD=$(realpath $REPO/builds/study-groups)
export VER=002pre3
#export VER=001react02
#export JSLIB="$(cat ./react.min.js)"
tools-build(){
  echo "Using version: $VER" 
  echo "Using template: $TEMPLATE" 
  echo "Using build dir:  $BUILD" 
  echo "Using assets dir:  $BUILD/assets" 
  rsync $TEMPLATE/styleguide.html $BUILD/$VER/
  rsync $TEMPLATE/error.html $BUILD/$VER/
  cat   $TEMPLATE/index.html | envsubst >  $BUILD/$VER/index.html

if [ -d "$BUILD/assets" ]; then
    echo "$BUILD/assets exists."
else
  ln -s $BUILD/assets $BUILD/$VER/assets
fi
  
  #cp -r $TEMPLATE/assets $BUILD/$VER/assets
}

tools-list-template(){
  ls -l $TEMPLATE
}

tools-list-build(){
  ls -l $BUILD/$VER 
}

tools-list-builds(){
  ls -l $BUILD/
}

tools-publish(){
  local tmpdir="/tmp/$(date +%s)"
  mkdir $tmpdir
  cp -r $BUILD/$VER/* /$tmpdir/
  git checkout gh-pages
  echo Using Repo: $REPO
  echo Continue? Hit ctrl-c to exit, return to continue.
  read varname
  cd $REPO
  git rm -r ./*
  cp -r $tmpdir/* .
  git add .
  git commit -m"Publishing version $VER."
  git push origin gh-pages
  rm -rf $tmpdir
  git checkout main
}

tools-clean(){
  echo executing: rm -r $BUILD/$VER
  rm -r $BUILD/$VER
}

tools-show-nginx(){
  cat /etc/nginx/sites-enabled/study-groups.org
}

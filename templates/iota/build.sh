export SEC1_HTML=$(cat sec1.html)
export SEC2_HTML=$(cat sec2.html)
export SEC3_HTML=$(cat sec3.html)
export REFS_HTML=$(cat refs.html)

buildname="index.html"
destname="index-002.html"
destdir="../../builds/iota"
linkname="../../builds/iota/index.html"

cat index.env | envsubst > $buildname 
cp $buildname $destdir/$destname
cp -r  assets $destdir
cp styles.css $destdir/styles.css
ln -s $destdir/$destname $linkname


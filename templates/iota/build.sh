export SEC1_HTML=$(cat sec1.html)
export SEC2_HTML=$(cat sec2.html)
export SEC3_HTML=$(cat sec3.html)
export REFS_HTML=$(cat refs.html)

cat index.env | envsubst > index.html
cp index.html ../../builds/iota/index-002.html
cp styles.css ../../builds/iota/styles.css
cp -r  assets ../../builds/iota/
ln -s ../../builds/iota/index-002.html ../../builds/iota/index.html


gaia-components-to-html(){
   for component in $(ls -1 components/*.env)
   do
      local basename=$(basename $component)
      cat $component | envsubst > "html/${basename%.*}.html"
      echo "wrote to: html/${basename%.*}.html"
   done 
}

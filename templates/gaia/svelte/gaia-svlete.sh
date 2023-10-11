
gaia-svelte-install(){
    npm install -g sirv-cli

    npm install svelte \
    rollup \
    rollup-plugin-svelte \
    rollup-plugin-livereload \
    rollup-plugin-terser
}

gaia-svelte-generate(){
  [ ! -d ./src ] && mkdir ./src
  echo "<script></script><style></style><h1>Hello Gaia-Svelte!</h1>" > src/App.svelte

echo "import App from './App.svelte'; new App({ target: document.body });" > src/main.js


cat <<EOF > ./src/index.html

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gaia-Svelte</title>
    <link rel="stylesheet" href="build/bundle.css">
</head>
<body>
    <script src="build/bundle.js"></script>
</body>
</html>
EOF
}

gaia-svelte-build(){
  rollup -c
}
gaia-svelte-dev(){
  rollup -c -w
}

gaia-svelte-local(){
   sirv public
}

gaia-svelte-host(){
   sirv public --host
}

js-activate () 
{ 
    if [ -z "$js_ps1_orig" ]; then
        js_ps1_orig="$PS1";
    fi;
    ver=${1:-"node"};
    export NVM_DIR="$HOME/.nvm";
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh";
    [ -s "$NVM_DIR/bash_completion" ] && \
        source "$NVM_DIR/bash_completion";
    nvm use $ver;
    PS1="n:$js_ps1_orig"
}

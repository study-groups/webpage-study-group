build-help(){
cat << EOF
Requires following Bash environment variables to be set:
PROJECT -- project name, e.g. gaia
VER     -- integer number, will be a directory
TEMPLATE-- full path to development, e.g. template
BUILD   -- full path to build directory
WEB     -- full path on server, starts with webroot, not used!
EOF
}

# This is where to add custom build steps
build-template-to-build(){
   echo cp -r  $TEMPLATE $BUILD
   cp -r  $TEMPLATE $BUILD
}

# needs principal of least authority protocol
build-to-server() {
   rm -r $WEB
   cp -r  $BUILD $WEB
}

# needs principal of least authority protocol
build-to-remote-server() {

cat << EOF

  echo scp -r $BUILD $ROLE@$SERVER:$WEB
  scp -r $BUILD $ROLE@$SERVER:$WEB

EOF
}

# If you cant do build-to-server, run this as root on server.
# This would be like a pull request.
# Requires root can scp into developer's account.
build-from-server-get-build(){
  echo scp -r $LOCALROLE@$LOCALSERVER:$BUILD $WEB
  scp -r $LOCALROLE@$LOCALSERVER:$BUILD $WEB
}


nginx-restart-as-user(){
cat << EOF

Add following to sudo via visudo:
$USER hostname ALL=NOPASSWD: /bin/systemctl

https://dmitry.khlebnikov.net/2015/07/18/
should-we-use-sudo-for-day-to-day-activities/ 
EOF

sudo systemctl restart nginx
}

# Requires far side having SSH key access

webpage-gaia-install-from-server(){
  scp -r hirschro@study-groups.org:\
     /home/hirschro/src/webpage-study-group/production/gaia/001 \
    /var/www/gaia/
}

webpage-gaia-install-from-build() {
   cp -r  \
     /home/hirschro/src/webpage-study-group/production/gaia/001 \
    /var/www/gaia/
}

nginx-restart-as-user(){
#https://dmitry.khlebnikov.net/2015/07/18/
#should-we-use-sudo-for-day-to-day-activities/ 
}

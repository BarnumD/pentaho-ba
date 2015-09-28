#!/bin/bash
# The hypersonic database is only used for Sample data.  In a production environment it should not be needed.
#################################
## Start Pentaho Hypersonic DB ##
#################################
#Only run the hypersonic database in test tier.
if [[ $TIER == "TEST" ]]; then
  if [ ! -f "/opt/pentaho/server/biserver-ee/start-pentaho.sh" ]; then
    #If the service has not bee installed yet sleep for 15 minutes.  Otherwise sleep for 1 minute before starting.
    sleep 900
  else
	sleep 60
  fi
  echo "Starting Hypersonic DB"
  exec setuser pentaho $PENTAHO_HOME/server/biserver-ee/data/start_hypersonic.sh
fi

#Baseimage-Docker will try to launch this process repeatedly if it is allowed to exit.  Instead sleep
sleep 99999999
exit
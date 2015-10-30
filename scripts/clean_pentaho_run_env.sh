#!/bin/bash
#Cleans out temporary directories used by pentaho.
rm -rf /opt/pentaho/server/biserver-ee/tomcat/work/*
rm -rf /opt/pentaho/server/biserver-ee/tomcat/temp/*
rm -f /opt/pentaho/server/biserver-ee/tomcat/conf/Catalina/localhost/*
rm -rf /opt/pentaho/server/biserver-ee/pentaho-solutions/system/jackrabbit/repository/*

#Optionally clear logs
#rm -rf /opt/pentaho/server/biserver-ee/tomcat/logs/*
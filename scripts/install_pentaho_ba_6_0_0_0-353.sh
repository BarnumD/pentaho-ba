#!/bin/bash

#Double check if Pentaho is installed at all.
if [ ! -f "/opt/pentaho/server/biserver-ee/start-pentaho.sh" ]; then
  #Install Pentaho BA Server at version 6.0.0.0-353
  
  # Components to be installed
  COMPONENTS="biserver-ee"
  PLUGINS="paz-plugin-ee:pdd-plugin-ee:pentaho-mobile-plugin:pir-plugin-ee"
  PENTAHO_VERSION="6.0.0.0"
  PENTAHO_PATCH="353"
  PENTAHO_HOME="/opt/pentaho"

  ##################################
  # Bring down and install Pentaho #
  ##################################
  ## Get PBA EE - 2 options
  echo "Downloading packages.  This could take some time.";
  #1. Get from FTP (slow & requires credentials)
  #ENV USER=USER PASS=PASS
  #RUN wget -P /tmp --progress=bar:force ftp://${USER}:${PASS}@supportftp.pentaho.com/Enterprise%20Software/Pentaho_BI_Suite/${PENTAHO_VERSION}-GA/BA-Server/Archive%20Build/*
  #2. Get from dropbox.
  ### Download Pentaho Business Analytics & plugins   --- (Don't have pwd for ftp, above.  Used dropbox instead.)
  cd /tmp/pentaho;
  if [ ! -f "biserver-ee-6.0.0.0-353-dist.zip" ]; then wget --progress=dot -qO biserver-ee-6.0.0.0-353-dist.zip https://file.location.to/biserver-ee-6.0.0.0-353-dist.zip; fi
  if [ ! -f "paz-plugin-ee-6.0.0.0-353-dist.zip" ]; then wget --progress=dot -qO paz-plugin-ee-6.0.0.0-353-dist.zip https://file.location.to/paz-plugin-ee-6.0.0.0-353-dist.zip; fi
  if [ ! -f "pdd-plugin-ee-6.0.0.0-353-dist.zip" ]; then wget --progress=dot -qO pdd-plugin-ee-6.0.0.0-353-dist.zip https://file.location.to/pdd-plugin-ee-6.0.0.0-353-dist.zip; fi
  if [ ! -f "pir-plugin-ee-6.0.0.0-353-dist.zip" ]; then wget --progress=dot -qO pir-plugin-ee-6.0.0.0-353-dist.zip https://file.location.to/pir-plugin-ee-6.0.0.0-353-dist.zip; fi
  if [ ! -f "pentaho-mobile-plugin-6.0.0.0-353-dist.zip" ]; then wget --progress=dot -qO pentaho-mobile-plugin-6.0.0.0-353-dist.zip https://file.location.to/pentaho-mobile-plugin-6.0.0.0-353-dist.zip; fi
  if [ ! -f "pentaho-operations-mart-6.0.0.0-353-dist.zip" ]; then wget --progress=dot -qO pentaho-operations-mart-6.0.0.0-353-dist.zip https://file.location.to/pentaho-operations-mart-6.0.0.0-353-dist.zip; fi
 

# Unzip components, removing the archives as we go
  for PKG in $(echo ${COMPONENTS} | tr ':' '\n'); \
  do echo "Unzipping $PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip";
    unzip -q /tmp/pentaho/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip -d /tmp/pentaho;
	echo "$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}" > /opt/pentaho/automation/pentaho_bi_installed_version.txt;
    rm -rf /tmp/pentaho/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip;
  done


  #********************
  #*   Install BA     *
  #********************
  # Run the biserver-ee installer
  # Install pentaho-ee to /opt/pentaho
  echo "Installing biserver-ee";
  sed -- "s:<installpath>[a-zA-Z0-9/\-\.]*:<installpath>/opt/pentaho:g" /tmp/pentaho/build/auto-install.xml.default  > auto-install.xml;
  java -jar biserver-ee-${PENTAHO_VERSION}-${PENTAHO_PATCH}/installer.jar auto-install.xml 2>/dev/null;
  mkdir -p /opt/pentaho/server; 
  cp -R /opt/pentaho/biserver-ee /opt/pentaho/server; rm -rf /opt/pentaho/biserver-ee;
  rm -rf /tmp/pentaho/biserver-ee-${PENTAHO_VERSION}-${PENTAHO_PATCH}*
	
  #********************
  #* Install plugins  *
  #********************
  echo "Installing bi plugins";
  sed -- "s:<installpath>[a-zA-Z0-9/\-\.]*:<installpath>/opt/pentaho/server/biserver-ee/pentaho-solutions/system:g" /tmp/pentaho/build/auto-install.xml.default  > auto-install.xml;
  for PKG in $(echo ${PLUGINS} | tr ':' '\n');
  do echo "Unzipping $PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip...";
    unzip -q /tmp/pentaho/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip -d /tmp/pentaho;
    java -jar $PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}/installer.jar auto-install.xml 2>/dev/null;
    rm -rf /tmp/pentaho/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}*;
  done

  #*************************************
  #* Install operations mart DLL files *
  #*************************************
  ADDON="pentaho-operations-mart"
  echo "Installing bi Operations Mart DDL Files";
  sed -- "s:<installpath>[a-zA-Z0-9\/\-\.]*:<installpath>/tmp/pentaho/$ADDON-${PENTAHO_VERSION}-${PENTAHO_PATCH}:g" /tmp/pentaho/build/auto-install.xml.default > auto-install.xml;
  for PKG in $(echo ${ADDON} | tr ':' '\n');
  do echo "Unzipping $PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip...";
    unzip -q /tmp/pentaho/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip -d /tmp/pentaho;
    java -jar $PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}/installer.jar auto-install.xml 2>/dev/null;
	unzip -q $PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}/pentaho-operations-mart-ddl-${PENTAHO_VERSION}-${PENTAHO_PATCH}.zip -d /tmp/pentaho/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH};
	cp -R $PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}/postgresql/* $PENTAHO_HOME/server/biserver-ee/data/postgresql/
    #rm -rf /tmp/pentaho/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}*;
  done

  #******************************
  #* Install analysis EE plugin *
  #******************************  
  # Can comment this section out if we don't want this.
  #ADDON="pentaho-analysis-ee"
  #echo "Installing bi Analysis plugin";
  #for PKG in $(echo ${ADDON} | tr ':' '\n');
  #do sed -- "s:<installpath>[a-zA-Z0-9\/\-\.]*:<installpath>/tmp/pentaho/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}:g" /tmp/pentaho/build/auto-install.xml.default > auto-install.xml;
  #  echo "Unzipping $PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip...";
  #  unzip -q /tmp/pentaho/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip -d /tmp/pentaho;
  #  java -jar $PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}/installer.jar auto-install.xml 2>/dev/null;
  #	mkdir -p /opt/pentaho/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/lib/
  #  cp /tmp/pentaho/pentaho-analysis-ee-6.0.0.0-353/pentaho-analysis-ee/lib/pentaho-analysis-ee-5.4.0.1*.jar /opt/pentaho/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/lib/; 
  #  cp /tmp/pentaho/pentaho-analysis-ee-6.0.0.0-353/pentaho-analysis-ee/lib/infinispan-core-5.3.0.Final.jar /opt/pentaho/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/lib/; 
  #  cp /tmp/pentaho/pentaho-analysis-ee-6.0.0.0-353/pentaho-analysis-ee/lib/jboss-logging-3.1.1.GA.jar /opt/pentaho/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/lib/; 
  #  cp /tmp/pentaho/pentaho-analysis-ee-6.0.0.0-353/pentaho-analysis-ee/lib/jboss-marshalling-1.3.15.GA.jar /opt/pentaho/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/lib/; 
  #  cp /tmp/pentaho/pentaho-analysis-ee-6.0.0.0-353/pentaho-analysis-ee/lib/jboss-marshalling-river-1.3.15.GA.jar /opt/pentaho/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/lib/; 
  #  cp /tmp/pentaho/pentaho-analysis-ee-6.0.0.0-353/pentaho-analysis-ee/lib/jboss-transaction-api_1.1_spec-1.0.0.Final.jar /opt/pentaho/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/lib/; 
  #  cp /tmp/pentaho/pentaho-analysis-ee-6.0.0.0-353/pentaho-analysis-ee/lib/jgroups-3.3.1.Final.jar /opt/pentaho/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/lib/; 
  #  cp /tmp/pentaho/pentaho-analysis-ee-6.0.0.0-353/pentaho-analysis-ee/lib/staxmapper-1.1.0.Final.jar /opt/pentaho/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/lib/; 
  #  mkdir -p /opt/pentaho/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/classes/
  #	cp /tmp/pentaho/pentaho-analysis-ee-6.0.0.0-353/pentaho-analysis-ee/config/* /opt/pentaho/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/classes/; 
  #done
  #  rm -rf /tmp/pentaho/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}*; 
	
  #Enable USE_SEGMEN_CACHE ?  - Not required for smaller environments.
  
  #**********************************
  #*  Initialize & setup database   *
  #**********************************
  /scripts/initialize_pentaho_database.exp $PGPWD $pentaho_user_pwd $hibuser_pwd $jcr_user_pwd
  
  #*********************************
  #*  Configure Pentaho settings   *
  #*********************************
  #Set log directory.  Default settings result in error.  Setting absolute path.
  sed -r -i -- "s:\.\./logs/pentaho.log:$CATALINA_HOME/logs/pentaho.log:g" $PENTAHO_HOME/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/classes/log4j.xml
  sed -r -i -- "s:\.\./logs/osgi_pentaho.log:$CATALINA_HOME/logs/osgi_pentaho.log:g" $PENTAHO_HOME/server/biserver-ee/pentaho-solutions/system/osgi/log4j.xml

  #Set solution path
  sed -i '/<param-name>solution-path<\/param-name>.*/ {N; s#\(<param-name>solution-path<\/param-name>\).*<\/param-value>#\1\n\t\t<param-value>'"${PENTAHO_HOME}/server/biserver-ee/pentaho-solutions"'<\/param-value>#}' $CATALINA_HOME/webapps/pentaho/WEB-INF/web.xml
  
  # Get rid of sample data and disable HSQLDB
  #rm -f ${PENTAHO_HOME}/server/biserver-ee/pentaho-solutions/system/default-content/*.zip
  #perl -0777 -i -pe 's/(<!-- \[BEGIN HSQLDB DATABASES\] -->)(.*)(<!-- \[END HSQLDB DATABASES\] -->)/$1\n    <!--    $2-->\n    $3/smg' $CATALINA_HOME/webapps/pentaho/WEB-INF/web.xml
  #perl -0777 -i -pe 's/(<!-- \[BEGIN HSQLDB STARTER\] -->)(.*)(<!-- \[END HSQLDB STARTER\] -->)/$1\n    <!--    $2-->\n    $3/smg' $CATALINA_HOME/webapps/pentaho/WEB-INF/web.xml
  
  #Done installing pentaho ba.
else
  #Alrady installed?
  echo "Pentaho is already installed?"
fi
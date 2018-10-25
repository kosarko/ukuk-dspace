#!/bin/bash -e

touch /var/lib/dspace/buildlock
git pull
mvn clean
mvn package -Dmirage2.on=true
cp /opt/dspace.build/dspace.cfg /opt/dspace.build/dspace/target/dspace-installer/config/
cd /opt/dspace.build/dspace/target/dspace-installer
ant fresh_install
cd /opt/dspace.build/
#Rebuild https://stackoverflow.com/questions/6583502/how-do-i-update-a-tomcat-webapp-without-restarting-the-entire-service
#sudo systemctl restart tomcat
rm -f /var/lib/dspace/buildlock

#!/bin/bash

#########################################################
#
# Script to Launch the Project
#
# Use it instead of docker-compose up (--build)
#
##########################################################


echo ""
echo "------------------------------------------------------"
echo "    ...Creating and building The Project ..."
echo "------------------------------------------------------"
echo ""
echo " README: "
echo " please note the OS image MUST be created before"
echo " see the ubuntu README for more information" 
echo ""


echo "------------------------------------------------------"
echo "       Checking Proxy Parameters ..."
echo "------------------------------------------------------"
echo ""

# la variable d'environnement proxyON est mise en place par le script dans .bashrc

proxyON=`env | grep -i PROXY=ON | wc -l`
if [ $proxyON -eq 1 ] ; then
  echo "  [+] Proxy is ON  =>  Enabling Python HTTP Server"
  CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  . $CURDIR/../local_repo/start.sh
else
  echo "Proxy is OFF"
fi

echo ""
echo "------------------------------------------------------"
echo "       Checking Docker Networks & Process ..."
echo "------------------------------------------------------"
echo ""
echo "Networks"
echo ""
docker network ls
echo ""
echo ""
docker ps
sleep 3
echo ""

echo "------------------------------------------------------"
echo "   [+]  Building Project : docker-compose up --build"
echo "------------------------------------------------------"
echo ""
echo "Removing Consul & Grafana container and volumes ..."
echo ""
docker rm consul grafana  2>/dev/null ; docker volume prune -f 
echo ""
echo "Building project ..."
echo ""
docker-compose up --build

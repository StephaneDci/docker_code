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
echo ""
echo "------------------------------------------------------"
echo "       Starting Local Repo ..."
echo "------------------------------------------------------"
echo ""

CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $CURDIR/../local_repo/start.sh

echo ""
echo "------------------------------------------------------"
echo " Building Base image "
echo "------------------------------------------------------"
echo ""

#docker build --network=glpi_admin . -t glpi_alpine_base -f ../alpine_base/Dockerfile

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

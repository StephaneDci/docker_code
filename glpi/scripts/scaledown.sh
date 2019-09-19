#!/bin/bash

###########################################
#
# Script to Scaledown a phpnode 
#
###########################################


echo $# arguments

if [ "$#" -ne 1 ]; then
    echo "Container ID needed"
    exit 1
fi

echo ""
echo "----------------------------------------"
echo "        Scaling Down Container ..."
echo "----------------------------------------"
echo ""
echo "----------------------------------------"
echo "   [+} Stopping the container ..."
echo "----------------------------------------"
echo ""
docker rm -f $1
echo ""
echo "----------------------------------------"
echo "   [+]  Deleting the associated keys ..."
echo "----------------------------------------"
echo ""
curl -S --request DELETE http://127.0.0.1:8500/v1/kv/php-apache/node/$1
echo ""
echo "----------------------------------------"
echo "               DONE !"
echo "----------------------------------------"

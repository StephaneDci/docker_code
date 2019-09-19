#!/bin/bash

echo "================================================"
echo "  STARTING GRAFANA CONTAINER : $HOSTNAME " 
echo "================================================"
echo ""
echo "Creating Directory /var/lib/grafana/dashboards .."
mkdir -p /var/lib/grafana/dashboards

# NOT NECESSARY SINCE GRAFANA 5.X THAT HAS SPECIFIC PROVISIONING
#echo ""
#echo "-------------------------------------------------"
#echo "Creating Prometheus Datasource in 10 seconds.."
#echo "-------------------------------------------------"
#echo ""
# Trick 1 : sleep 10 : enable to ensure entrypoint is executed and container/port accessible
# Trick 2 : using API rest of Grafana to create the Datasource on Prometheus (not a real trick ;-))
# Trick 3 : lauch in background in order  
#(sleep 10 && echo "Creating DS now!" && curl -s --user admin:admin 'http://127.0.0.1:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"DS_Prometheus","isDefault":true ,"type":"prometheus","url":"http://prometheus:9090","access":"proxy","basicAuth":false}' --noproxy 127.0.0.1)&

# run REAL entrypoint of the image
/run.sh

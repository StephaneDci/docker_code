- Contributers : Stéphane / ...
- Date         : 02.04.2018
----------------------------------------------------------------------------------------------------

#  POC  with Docker-Compose
 Version      : 1.4

#  Description : 

##    -> Execution Layer 
        - Custom OS : image based on alpine
        - Phpnode : (stateless & scalable) : apache / php that get code source from REPO (ie glpi)
        - Varnish caching (with dynamic configuration with confd / consul)
        - Mysql Database with replication
        - Service Discovery and Key Value Database with consul

Also in this Execution Layer : 

        - startup container : used to register values in Consul KV
        - python-api-consul : used to retrieve values in Consul KV

##    -> Supervision Layer
        - Cadvisor (for metrics of containers)
	- Node-Exporter (for prometheus metrics on node)
        - Prometheus
        - Grafana  (for Dashboarding) , automatic deployment of Dashboard and automate DS creation

## TODO BACKLOG ( Proposed Features ) 
        - CORE:          Migrate from compose to Kubernetes and deploy via K8s yaml
        - CORE:          Provisioning K8s  with Terraform / Ansible (or VM for 1st Step)
        - CORE:          if not K8S provision with CoreOS / fleet
        - CONTAINER:	 Add a user in Dockerfile to replace root user
        - SECU:          Find technical way for confidential information (ie proxy credentials)
        - OS:            Try to build confd with multistage boot to have smallest image possible
        - OS:            Integrate build of OS image in docker-compose file if possible
        - CONSUL:        Use Service Discovery of Consul and DNS (usage to define ;-))
        - STORAGE :      Migrate data Volume on cloud (AWS ... )
        - CONFD/MYSQLD:  Integrate confd in mysql Image in order to be able to push dynamic configuration (be careful with master/slave config)
        - CONFD/HTTPD:   Generate  HTTPD VHOST conf with confd and dynamic config instead of script
        - CONFD:         Integrate Key to enable execution command in container (where to store / display result to define)
        - PROMETHEUS:    Integrate alerting configuration into prometheus
        - NETWORK :      Validate Drivers to use (Host / Bridge / null) for the different created networks

## CHANGELOG

	- 01.04.18 	Adding a node-exporter for Prometheus in docker-compose
	- 01.04.18	Adding a "startup" temporary container for executing some scripts (registering KV)
	- 05.04.18	Adding context in docker-compose for each image to be able to build each image outside of docker-compose if needed
	- 07.04.18	Adding Construction of Mysql Image & Configuration to enable scaling of Mysql Slave Containers
        - 14.04.18      Adding python-api-consul container to enable retrieveing of some KV in consul
        - 21.04.18      Adding script to change configuration of proxy (http_proxy / pip configuration & confd url)
        - 01.05.18      Adding capabilities of local python webserver in container (in case of proxy issue on some binaries => ie confd)
                        LOCAL-REPO: Write down an HTTP-server that enable client behind proxy to download some files
                        API-CONSUL:    Define an applicative API in order to enable client to get value in KV
        - 07.05.18      Remove Expose command in docker-compose.yml when port directive was present
	- 15.01.20	Migrate to Alpine Image
	- Please See Changelog of each Section for more information

=====================================================================================================

NB :apache php Node is Based on  https://github.com/driket/docker-glpi


##  Build OS image
### Based on Alpine & containing confd & some more tools (net-tools,wget, curl)

cd alpine_base
docker network create -d bridge glpi_admin
docker build . -t alpine_base --network=glpi_admin

##  Run docker-compose (necessary to destroy consul datavolume)

docker rm consul
docker volume prune -f
docker-compose up --build

OR

./scripts/build.sh

### Configure new database at 1st installation

server :  db
user :    glpi
password: glpipaswd 

schema :  glpi

For the replicated MYSQL image is based on 
https://github.com/bergerx/docker-mysql-replication

### To Access Varnish frontend :
Varnish  access : http://127.0.0.1:8080

### To Connect to GLPI interface
glpi / glpi
tech / tech

### To scale UP apache-php Node

docker-compose scale nodephp=x+1
ie  docker-compose scale nodephp=2
Note that Varnish configuration will adjust dynamically via confd

### To scale DOWN apache-php Node

Note that Varnish configuration will NOt adjust dynamically via confd when downscaling
docker-compose scale nodephp=x-1
AND supress the keys in CONSUL KV

# Monitoring Layers with cadvisor / prometheus / grafana
### https://blog.eleven-labs.com/fr/monitorer-ses-containers-docker/
cadvisor      http://127.0.0.1:8005/docker
prometheus    http://127.0.0.1:9090/targets
grafana       http://127.0.0.1:3000    access via admin/admin

Add Datasource Prometheus via UI
		http://localhost:3000/datasources/new
		Name Prometheus / Type: Prometheus / Access : Proxy / url : http://prometheus:9090

    or via curl done with container starting 
curl --user admin:admin 'http://127.0.0.1:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"test","isDefault":true ,"type":"prometheus","url":"http://localhost:9090","access":"proxy","basicAuth":false}'

import dashboard : https://grafana.com/dashboards/179 or in prometheus folder copy paste the JSON

# CONSUL README
https://github.com/JoergM/consul-examples/tree/master/http_api

### Query All registered Services : 
curl localhost:8500/v1/catalog/services

### Query specific service :        
curl localhost:8500/v1/catalog/services/example

### Register Service
curl -X PUT -d @service.json localhost:8500/v1/agent/service/register

####service.json file
{
  "ID": "example2",
  "Name": "example2",
  "Tags": [
    "specific",
    "v1"
  ],
  "Address": "127.0.0.1",
  "Port": 8000
}

### Find all KV registered under /php/node
curl http://127.0.0.1:8500/v1/kv/php-apache/node/?keys
["php-apache/node/483ddc22a3b7","php-apache/node/ed5bbbc6d3ab"]

Or

curl http://127.0.0.1:8500/v1/kv/php-apache/node/?recurse
[{"CreateIndex":32,"ModifyIndex":32,"LockIndex":0,"Key":"php-apache/node/483ddc22a3b7","Flags":0,"Value":"NDgzZGRjMjJhM2I3"},{"CreateIndex":28,"ModifyIndex":28,"LockIndex":0,"Key":"php-apache/node/ed5bbbc6d3ab","Flags":0,"Value":"ZWQ1YmJiYzZkM2Fi"}]

# CONFD Watch modification on Consul KV for container a lancer dans les containers
/opt/confd/bin/confd -config-file /etc/confd/conf.d/confd-config.toml -backend consul -node consul:8500 -interval 5


# UPGRADE Configuration of container from host with Consul KV & confd

### Varnish Defaut (to launch from host)
curl -s -X PUT -d '100'     http://127.0.0.1:8500/v1/kv/varnish/confvcl/maxconnectionbe
curl -s -X PUT -d '5'       http://127.0.0.1:8500/v1/kv/varnish/confvcl/betimeout
curl -s -X PUT -d '10s'     http://127.0.0.1:8500/v1/kv/varnish/confvcl/probeinterval

### Apache Defaut
curl -s -X PUT -d '5'   http://127.0.0.1:8500/v1/kv/php-apache/prefork/startserver
curl -s -X PUT -d '5'   http://127.0.0.1:8500/v1/kv/php-apache/prefork/minspare
curl -s -X PUT -d '10'  http://127.0.0.1:8500/v1/kv/php-apache/prefork/maxspare
curl -s -X PUT -d '150' http://127.0.0.1:8500/v1/kv/php-apache/prefork/maxworker
curl -s -X PUT -d '0'   http://127.0.0.1:8500/v1/kv/php-apache/prefork/maxconn


## Docker Usage
### Docker Engine Proxy
systemctl show --property=Environment docker
To modify it:  /etc/systemd/system/docker.service.d/http-proxy.conf
then systemctl daemon-reload ; service docker restart'

### Container Proxy
put ENV in Dockerfile

### DockerFile Proxy
use ARG and value in docker-compose

## GIT
### Git configuration
- git config --global https.proxy https://.../ (or "" for erase proxy)
- git config --global http.proxy http://.../
- git config --global user.name "Stéphane D."
- git config --global user.email "stephane.dicioccio.web@gmail.com"
- git config --global http.sslVerify false
### Git Initialisation from existing Folders
- cd folder
- git init
- git add .
- git remote remove origin
- git commit -m "Initial Commit - Stephane"
- git remote add origin https://github.com/StephaneDci/docker_code.git
- git push -v -u origin master
### Git usage
- git pull                              : to retrieve from repo to be sure to be up to date
- git status                            : to see what status between local & remote 
- git commit -am "message"              : to add all new files in the commit (otherwise go with git add <files> for example)
- git push -v -u origin master          : to commit modification on repo

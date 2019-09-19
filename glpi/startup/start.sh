#!/bin/sh
#
# Script Modifying Configuration File with API Python (v1 or v2)
#

sleep 1
echo "------------------------------------------------"
echo " STARTUP SCRIPT FOR REGISTRING KEYS IN CONSUL   " 
echo "------------------------------------------------"
echo ""
echo "------------------------------------------------"
echo " >> NODEPHP: Consul Registering Config Keys ... "
echo "------------------------------------------------"
echo ""
echo "MPM Prefork Keys"
echo ""
echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/prefork/startserver&val=5\" "
echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/prefork/minspare&val=5\"    "
echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/prefork/maxspare&val=10\"    "
echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/prefork/maxworker&val=150\"   "
echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/prefork/maxconn&val=0\"     "

curl -s "http://python-api-consul:5000/setval?key=php-apache/prefork/startserver&val=5" --noproxy python-api-consul
curl -s "http://python-api-consul:5000/setval?key=php-apache/prefork/minspare&val=5"    --noproxy python-api-consul
curl -s "http://python-api-consul:5000/setval?key=php-apache/prefork/maxspare&val=10"   --noproxy python-api-consul
curl -s "http://python-api-consul:5000/setval?key=php-apache/prefork/maxworker&val=150" --noproxy python-api-consul
curl -s "http://python-api-consul:5000/setval?key=php-apache/prefork/maxconn&val=0"     --noproxy python-api-consul
echo ""
echo "PHP.ini Keys"
echo ""
echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/php/opcachesize&val=128M\" "
echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/php/maxacceleratedfiles&val=5000\" "
echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/php/exposephp&val=Off\" "
echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/php/memorylimit&val=128M\" "
echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/php/postmaxsize&val=8M\" "
echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/php/uploadmaxsize&val=8M\" "

curl -s "http://python-api-consul:5000/setval?key=php-apache/php/opcachesize&val=128M"         --noproxy python-api-consul
curl -s "http://python-api-consul:5000/setval?key=php-apache/php/maxacceleratedfiles&val=5000" --noproxy python-api-consul
curl -s "http://python-api-consul:5000/setval?key=php-apache/php/exposephp&val=Off"            --noproxy python-api-consul
curl -s "http://python-api-consul:5000/setval?key=php-apache/php/memorylimit&val=128M"         --noproxy python-api-consul
curl -s "http://python-api-consul:5000/setval?key=php-apache/php/postmaxsize&val=8M"           --noproxy python-api-consul
curl -s "http://python-api-consul:5000/setval?key=php-apache/php/uploadmaxsize&val=8M"         --noproxy python-api-consul
echo ""
echo "---------------------------------------------------"
echo " >> VARNISH: Consul Registering Config Keys ... "
echo "---------------------------------------------------"
echo ""
# todo migration du status sur l'API
echo "curl -s -X PUT -d 'GET /status.php HTTP/1.1' http://consul:8500/v1/kv/varnish/confvcl/urihealthcheck"
#echo "curl -s \"http://python-api-consul:5000/setval?key=varnish/confvcl/urihealthcheck&val=GET /status.php HTTP/1.1\" "
echo "curl -s \"http://python-api-consul:5000/setval?key=varnish/confvcl/maxconnectionbe&val=100\" "
echo "curl -s \"http://python-api-consul:5000/setval?key=varnish/confvcl/betimeout&val=5s\" "
echo "curl -s \"http://python-api-consul:5000/setval?key=varnish/confvcl/probeinterval&val=15s\" "

# todo migration du status sur l'API
curl -s -X PUT -d 'GET /status.php HTTP/1.1' http://consul:8500/v1/kv/varnish/confvcl/urihealthcheck --noproxy consul
#curl -s "http://python-api-consul:5000/setval?key=varnish/confvcl/urihealthcheck&val=GET%20/status.php%20HTTP/1.1"    --noproxy python-api-consul
curl -s "http://python-api-consul:5000/setval?key=varnish/confvcl/maxconnectionbe&val=100"    --noproxy python-api-consul
curl -s "http://python-api-consul:5000/setval?key=varnish/confvcl/betimeout&val=5s"           --noproxy python-api-consul
curl -s "http://python-api-consul:5000/setval?key=varnish/confvcl/probeinterval&val=15s"      --noproxy python-api-consul
echo ""
sleep 1

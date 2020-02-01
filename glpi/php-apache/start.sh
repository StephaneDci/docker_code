#!/bin/ash
#######################################################################################
#   Configuration of Apache PHP Node (Scalable)
#
# - Install GLPI if not already installed
# - Register consul KV for confd
# - Copy Apache VHOST configuration (NEW, before was regexp remplacement)
# - Run apache in foreground
#
#######################################################################################

/usr/sbin/httpd -k stop

echo "=========================================================="
echo ""
echo "  START TO CONFIGURE PHP-APACHE CONTAINER: $HOSTNAME"
echo ""
echo "=========================================================="

APACHE_DIR="/var/www/html"
APACHE_MAIN_CONF="/etc/apache2/conf.d/httpd.conf"
GLPI_DIR="${APACHE_DIR}/glpi"
VHOST="/etc/apache2/conf.d/000-glpi.conf"
HTACCESS="/var/www/html/.htaccess"

# Si le version n'est pas renseignée dans l'ENV alors la version par defaut est decrite ici
GLPI_SOURCE_URL=${GLPI_SOURCE_URL:-"https://github.com/glpi-project/glpi/releases/download/9.4.5/glpi-9.4.5.tgz"}


# le hostname pour varnish du ou des containers crées avec l'image instancié
# Permet de gérer dans Varnish la scalabilité de ce container
echo ""
echo "-------------------------------------------------"
echo " >> Confd: ADD DOCKER HOSTNAME in CONSUL KV "
echo "-------------------------------------------------"
echo ""

echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/node/$HOSTNAME&val=$HOSTNAME\" "
curl -s "http://python-api-consul:5000/setval?key=php-apache/node/$HOSTNAME&val=$HOSTNAME" --noproxy python-api-consul


echo ""
echo "--------------------------------------------------"
echo " >>INSTALL GLPI IF NOT INSTALLED ALREADY "
echo "--------------------------------------------------"
echo ""

if [ "$(ls -A $GLPI_DIR/index.php)" ]; then
  echo "GLPI is already installed at ${GLPI_DIR}"
else
  echo '-----------> Installing GLPI ...'
  echo "Using ${GLPI_SOURCE_URL}"
  curl -k -L -o /tmp/glpi.tar.gz $GLPI_SOURCE_URL
  tar -C $APACHE_DIR -xzf /tmp/glpi.tar.gz
  chown -R apache $GLPI_DIR
fi

# REMOVE THE DEFAULT INDEX.HTML TO LET HTACCESS REDIRECTION 
rm ${APACHE_DIR}/index.html


echo ""
echo "--------------------------------------------------"
echo " >> CONFIGURE APACHE VHOST ..."
echo "--------------------------------------------------"
echo ""
cat $VHOST

chown apache .
chown apache -R $GLPI_DIR

# Ajout SDI
# Desactivate ETAG & Specific LogFormat & HTTP request header
#echo "# Desactivate ETAG On Apache" >> $APACHE_MAIN_CONF
#echo "FileETag None" >>      $APACHE_MAIN_CONF
#sed -i '/vhost_combined/a LogFormat \"%{X-Forwarded-For}i %{True-Client-IP}i %{X-CDN}i %{Host}i %h %l %u %t \\\"%r\\\" %>s %b %T\" log-cf' $APACHE_MAIN_CONF
echo 'export HOSTNAME=`uname -n`' >> /etc/apache2/envvars
sed -i '/DocumentRoot/a Header set apachehost ${HOSTNAME}' $VHOST

#Enable to Access server-status with local IP
#ipdocker=`ifconfig | grep eth0 -A 2 | grep inet | tr -s " " | cut -d " " -f3 | cut -d "." -f1-3 | sed 's#$#.0/24#g'`
#sed -i "s#local#ip $ipdocker#g" /etc/apache2/mods-enabled/status.conf
#sed -i "s#local#ip 127.0.0.1#g" /etc/apache2/conf.d/glpistatus.conf


# create file status.php in GLPI root for varnish healthcheck
echo "<?php  ?>" > ${GLPI_DIR}/status.php
chown apache ${GLPI_DIR}/status.php



## Surveillance des modifications via confd / consul
echo ""
echo "-------------------------------------------------"
echo " >> APACHE: Confd: init watcher of modif "
echo "-------------------------------------------------"

echo ""
echo "(/opt/confd/bin/confd -config-file /etc/confd/conf.d/confd-mpm-prefork.toml -backend consul -node consul:8500 -interval 5)&"
(sleep 4 ; /opt/confd/bin/confd -config-file /etc/confd/conf.d/confd-mpm-prefork.toml -backend consul -node consul:8500 -interval 5)&
echo ""
echo "(/opt/confd/bin/confd -config-file /etc/confd/conf.d/confd-php.ini.toml -backend consul -node consul:8500 -interval 5)&"
(sleep 4 ; /opt/confd/bin/confd -config-file /etc/confd/conf.d/confd-php.ini.toml -backend consul -node consul:8500 -interval 5)&

# TO DEBUG initialy to perform any action on multiple container
#echo ""
#echo "(/opt/confd/bin/confd -config-file /etc/confd/conf.d/confd-exec-cmd.toml -backend consul -node consul:8500 -interval 5)&"
#(sleep 4 ; /opt/confd/bin/confd -config-file /etc/confd/conf.d/confd-php.ini.toml -backend consul -node consul:8500 -interval 5)&

## RUN APACHE IN FOREGROUND 
echo ""
echo "-------------------------------------------------"
echo " >> RESTARTING APACHE "
echo "-------------------------------------------------"

/usr/sbin/httpd -k start -D BACKGROUND
# start apache in foreground
# source /etc/apache2/envvars
# /usr/sbin/apache2 -D FOREGROUND

echo ""
echo "-------------------------------------------------"
echo " END OF CONFIGURATION OF PHP-APACHE "
echo "-------------------------------------------------"
echo ""

tail -f /var/log/apache2/error.log -f /var/log/apache2/access.log

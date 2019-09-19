#!/bin/bash
#######################################################################################
#   Configuration of Apache PHP Node (Scalable)
#
# - Install GLPI if not already installed
# - Register consul KV for confd
# - Copy Apache VHOST configuration (NEW, before was regexp remplacement)
# - Run apache in foreground
#
#######################################################################################

echo "=========================================================="
echo ""
echo "  START TO CONFIGURE PHP-APACHE CONTAINER: $HOSTNAME"
echo ""
echo "=========================================================="

APACHE_DIR="/var/www/html"
APACHE_MAIN_CONF="/etc/apache2/apache2.conf"
GLPI_DIR="${APACHE_DIR}/glpi"

# Si le version n'est pas renseignée dans l'ENV alors la version par defaut est GLPI 0.85.4
GLPI_SOURCE_URL=${GLPI_SOURCE_URL:-"https://forge.glpi-project.org/attachments/download/2020/glpi-0.85.4.tar.gz"}


# le hostname pour varnish du ou des containers crées avec l'image instancié
# Permet de gérer dans Varnish la scalabilité de ce container
echo ""
echo "-------------------------------------------------"
echo " >> Confd: ADD DOCKER HOSTNAME in CONSUL KV "
echo "-------------------------------------------------"
echo ""
# Old method on Consul / NEW on Api
#echo 'curl -s -X PUT -d "$HOSTNAME"   http://consul:8500/v1/kv/php-apache/node/$HOSTNAME'
#curl -s -X PUT -d "$HOSTNAME"   "http://consul:8500/v1/kv/php-apache/node/$HOSTNAME" --noproxy consul
echo "curl -s \"http://python-api-consul:5000/setval?key=php-apache/node/$HOSTNAME&val=$HOSTNAME\" "
curl -s "http://python-api-consul:5000/setval?key=php-apache/node/$HOSTNAME&val=$HOSTNAME" --noproxy python-api-consul


echo ""
echo "--------------------------------------------------"
echo " >>INSTALL GLPI IF NOT INSTALLED ALREADY "
echo "--------------------------------------------------"
echo ""

if [ "$(ls -A $GLPI_DIR)" ]; then
  echo "GLPI is already installed at ${GLPI_DIR}"
else
  echo '-----------> Installing GLPI ...'
  echo "Using ${GLPI_SOURCE_URL}"
  wget -O /tmp/glpi.tar.gz $GLPI_SOURCE_URL --no-check-certificate
  tar -C $APACHE_DIR -xzf /tmp/glpi.tar.gz
  chown -R www-data $GLPI_DIR
fi

# REMOVE THE DEFAULT INDEX.HTML TO LET HTACCESS REDIRECTION 
rm ${APACHE_DIR}/index.html

VHOST=/etc/apache2/sites-enabled/000-default.conf

echo ""
echo "--------------------------------------------------"
echo " >> CONFIGURE APACHE VHOST ..."
echo "--------------------------------------------------"
echo ""
cat /etc/apache2/sites-enabled/000-default.conf

# HTACCESS="/var/www/html/.htaccess"
# /bin/cat <<EOM >$HTACCESS
# RewriteEngine On
# RewriteRule ^$ /glpi [L]
# EOM
# chown www-data /var/www/html/.htaccess
chown www-data .

# Ajout SDI
# Desactivate ETAG & Specific LogFormat & HTTP request header
echo "# Desactivate ETAG On Apache" >> $APACHE_MAIN_CONF
echo "FileETag None" >>      $APACHE_MAIN_CONF
sed -i '/vhost_combined/a LogFormat \"%{X-Forwarded-For}i %{True-Client-IP}i %{X-CDN}i %{Host}i %h %l %u %t \\\"%r\\\" %>s %b %T\" log-cf' $APACHE_MAIN_CONF
echo 'export HOSTNAME=`uname -n`' >> /etc/apache2/envvars
sed -i '/DocumentRoot/a Header set apachehost ${HOSTNAME}' $VHOST

#Enable to Access server-status with local IP
ipdocker=`ifconfig | grep eth0 -A 2 | grep inet | tr -s " " | cut -d " " -f3 | cut -d "." -f1-3 | sed 's#$#.0/24#g'`
#sed -i "s#local#ip $ipdocker#g" /etc/apache2/mods-enabled/status.conf
sed -i "s#local#ip 127.0.0.1#g" /etc/apache2/mods-enabled/status.conf


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
service apache2 restart

# start apache in foreground
# source /etc/apache2/envvars
# /usr/sbin/apache2 -D FOREGROUND
echo ""
echo "-------------------------------------------------"
echo " END OF CONFIGURATION OF PHP-APACHE "
echo "-------------------------------------------------"
echo ""


tail -f /var/log/apache2/error.log -f /var/log/apache2/access.log

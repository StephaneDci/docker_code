# Custom image build earlier
FROM ubuntu_artful:latest
MAINTAINER stephane 
LABEL "DESCRIPTION"="############# PHP7-HTTPD CONTAINER ##############"

# If Proxy needed or not
#ENV http_proxy ""
#ENV https_proxy ""

# Install apache2
RUN apt-get update && apt-get install -y apache2

# Install php & dependancy
RUN apt-get install -y --force-yes \
  php7.1 \
  php7.1-mysql \
  php7.1-ldap \
  php7.1-xmlrpc \
  php7.1-curl \
  php7.1-gd \
  php7.1-mbstring \
  php7.1-simplexml \
  php7.1-xml \
  php7.1-apcu \
  php7.1-imap

# Activation of modules & cleaning some dirs
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && a2enmod rewrite && a2enmod headers && service apache2 stop
WORKDIR /var/www/html
COPY start.sh /opt/
RUN chmod +x /opt/start.sh && usermod -u 1000 www-data

#apache mpm-prefork  template for confd
ADD confd-mpm-prefork.toml  /etc/confd/conf.d/confd-mpm-prefork.toml
ADD mpm_prefork.conf.tmpl   /etc/confd/templates/mpm_prefork.conf.tmpl

# php.ini template for confd
ADD confd-php.ini.toml     /etc/confd/conf.d/confd-php.ini.toml
ADD php.ini.tmpl           /etc/confd/templates/php.ini.tmpl

# apache Vhost config
ADD glpi_vhost.conf        /etc/apache2/sites-enabled/000-default.conf

#TODO
ENV no_proxy "consul"


CMD /opt/start.sh

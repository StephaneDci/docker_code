# Custom image build earlier
#FROM ubuntu_artful:latest
FROM glpi_alpine_base
MAINTAINER stephane 
LABEL "DESCRIPTION"="############# PHP-HTTPD CONTAINER ##############"


RUN apk add --update --no-cache bash \
				curl \
				php5-openssl \
				#php5-dba \
				#php5-pear \
				php5-pdo_mysql \
				php5-common \
				#php5-xsl \
				#php5-fpm \	
				#php5-mysql \
				php5-mysqli \
				#php5-pspell \
				php5-xmlrpc \
				#php5-embed \
				#php5-pdo_sqlite \
				php5-exif \
				php5-opcache \
				#php5-posix \	
				php5-gd  \
				#php5-gettext \
				php5-json \
				php5-xml \
				php5 \
				php5-iconv \
				#php5-sysvshm \
				php5-curl \
				#php5-odbc \
				php5-phar \
				#php5-pdo_pgsql \
				php5-imap \
				#php5-pdo_dblib \
				#php5-pdo_odbc \
				#php5-xdebug \
				#php5-zip \
				php5-apache2 \
				#php5-cgi \
				php5-ctype \
				#php5-mcrypt \
				#php5-wddx \
				#php5-bcmath \
				#php5-calendar \
				#php5-dom \
				#php5-sockets \
				#php5-soap \
				php5-apcu \
				#php5-sysvmsg \
				php5-zlib \
				#php5-ftp \
				#php5-sysvsem \ 
				php5-pdo \
				#php5-bz2 \
  				apache2 \
				#libxml2-dev \
				apache2-utils


RUN curl -sS https://getcomposer.org/installer | php5 -- --install-dir=/usr/bin --filename=composer 
RUN rm -rf /var/cache/apk/*
RUN mkdir -p /run/apache2

WORKDIR /var/www/html
COPY start.sh /opt/
RUN chmod +x /opt/start.sh

#apache mpm-prefork  template for confd
ADD confd-mpm-prefork.toml  /etc/confd/conf.d/confd-mpm-prefork.toml
ADD mpm_prefork.conf.tmpl   /etc/confd/templates/mpm_prefork.conf.tmpl

# php.ini template for confd
ADD confd-php.ini.toml     /etc/confd/conf.d/confd-php.ini.toml
ADD php.ini.tmpl           /etc/confd/templates/php.ini.tmpl

# apache config
ADD glpi_vhost.conf        /etc/apache2/conf.d/000-glpi.conf
ADD glpi_httpd.conf        /etc/apache2/httpd.conf

#TODO
ENV no_proxy "consul"

CMD /opt/start.sh
#CMD /bin/ash 

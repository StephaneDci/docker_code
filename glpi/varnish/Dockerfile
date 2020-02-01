# This is a custom image of ubuntu:artful build earlier for the app
FROM       glpi_alpine_base 
LABEL "DESCRIPTION"="############## VARNISH CONTAINER ##############"
MAINTAINER  Stephane 
ENV DEBIAN_FRONTEND noninteractive

#HEALTHCHECK  --interval=5s --timeout=3s --retries=3 CMD curl -SI 127.0.0.1:6081 | grep 200
#ENV http_proxy "http://
#ENV https_proxy "https://

# Install base system
RUN apk add --update --no-cache varnish bash curl
RUN rm -rf /var/cache/apk/*

# Make our custom VCLs available on the container
ADD default.vcl /etc/varnish/default.vcl

# confd configuration 
COPY confd-config.toml     /etc/confd/conf.d/confd-config.toml
COPY default.vcl.conf.tmpl /etc/confd/templates/default.vcl.conf.tmpl
# to properly restart varnish once configuration change
COPY varnish-restart.sh    /opt/varnish-restart.sh
COPY start /start

ENV no_proxy "consul"

RUN chmod 0755 /start 
CMD ["/start"]

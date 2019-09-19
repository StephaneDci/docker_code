# This is a custom image of ubuntu:artful build earlier for the app
FROM        ubuntu_artful
LABEL "DESCRIPTION"="############## VARNISH CONTAINER ##############"
MAINTAINER  Stephane 
ENV DEBIAN_FRONTEND noninteractive

#HEALTHCHECK  --interval=5s --timeout=3s --retries=3 CMD curl -SI 127.0.0.1:6081 | grep 200

#ENV http_proxy ""
#ENV https_proxy ""

# Install base system
RUN apt-get update
RUN apt-get install -y varnish

# A little bit of cleaning
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Make our custom VCLs available on the container
#ADD /varnish/default.vcl /etc/varnish/default.vcl
COPY start /start

# confd configuration 
COPY confd-config.toml     /etc/confd/conf.d/confd-config.toml
COPY default.vcl.conf.tmpl /etc/confd/templates/default.vcl.conf.tmpl
# to properly restart varnish once configuration change
COPY varnish-restart.sh    /opt/varnish-restart.sh

ENV no_proxy "consul"


RUN chmod 0755 /start 
CMD ["/start"]

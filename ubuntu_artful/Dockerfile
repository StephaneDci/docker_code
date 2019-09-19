FROM        ubuntu:artful
MAINTAINER  Stephane 
 
ENV DEBIAN_FRONTEND noninteractive
LABEL "Description"="############ OS image up to date for App ##########"
LABEL "Usage"="docker build . -t ubuntu_artful"

# Definition Proxy
#ENV http_proxy ""
#ENV https_proxy ""

# Update the package repository
RUN apt-get update

# Install base system and tools needed
RUN apt-get install -y wget curl vim net-tools lsof iputils-ping

# A little bit of cleaning
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/vim && rm -rf /usr/share/man && rm -rf /usr/share/doc*

# install confd
# NB this will not work with Carrefour Proxy (unauthorized)
RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.15.0/confd-0.15.0-linux-amd64
RUN mkdir -p /opt/confd/bin && mv confd-0.15.0-linux-amd64 /opt/confd/bin/confd && chmod +x /opt/confd/bin/confd && mkdir -p /etc/confd/{conf.d,templates}

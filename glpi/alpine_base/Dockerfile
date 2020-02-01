FROM        alpine:3.5
MAINTAINER  Stephane 
 
ENV DEBIAN_FRONTEND noninteractive
LABEL "Description"="############ OS image up to date for App ##########"
LABEL "Usage"="docker build . -t alpine_base"

# Update the package repository
RUN apk update

# Install base system and tools needed
RUN apk add bash wget curl lsof

# install confd from local image
RUN wget http://http-server:6789/confd-0.15.0-linux-amd64 --no-proxy
RUN mkdir -p /opt/confd/bin && mv confd-0.15.0-linux-amd64 /opt/confd/bin/confd && chmod +x /opt/confd/bin/confd && mkdir -p /etc/confd/{conf.d,templates}

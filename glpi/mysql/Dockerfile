FROM bergerx/mysql-replication:5.7
LABEL "Description"="############ Mysql master-Slave: Container image ###########"

##
## Surcouche pour installer les outils et confd
##

# Definition Proxy
#ENV http_proxy ""
#ENV https_proxy ""

# Update the package repository
RUN apt-get update --allow-unauthenticated

# Install base system and tools needed
RUN apt-get install -y wget curl vim net-tools lsof iputils-ping 


#install confd
RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.15.0/confd-0.15.0-linux-amd64
RUN mkdir -p /opt/confd/bin && mv confd-0.15.0-linux-amd64 /opt/confd/bin/confd && chmod +x /opt/confd/bin/confd && mkdir -p /etc/confd/{conf.d,templates}

# A little bit of cleaning
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/vim && rm -rf /usr/share/man && rm -rf /usr/share/doc*

##
## DockerFile Original for image
##
ENV REPLICATION_USER replication
ENV REPLICATION_PASSWORD replication_pass
COPY replication-entrypoint.sh /usr/local/bin/
#COPY getserveridnum.py /usr/local/bin/
COPY init-slave.sh /
ENTRYPOINT ["replication-entrypoint.sh"]
CMD ["mysqld"]

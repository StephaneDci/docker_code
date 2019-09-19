#!/bin/bash

#############################################################
#
# Construction de la configuration 
#
#############################################################

set -eo pipefail

echo "====================================";
echo " Mysql : replication-entrypoint.sh  ";
echo "====================================";


cat > /etc/mysql/mysql.conf.d/repl.cnf << EOF
[mysqld]
log-bin=mysql-bin
relay-log=mysql-relay
#bind-address=0.0.0.0
#skip-name-resolve
EOF

# If there is a linked master use linked container information
if [ -n "$MASTER_PORT_3306_TCP_ADDR" ]; then
  export MASTER_HOST=$MASTER_PORT_3306_TCP_ADDR
  export MASTER_PORT=$MASTER_PORT_3306_TCP_PORT
fi

if [ -z "$MASTER_HOST" ]; then
   echo Initializing MASTER Server ID;
   #SERVER ID via API Consul
   curl -s "http://python-api-consul:5000/setval?key=mysqld/serverid&val=1" --noproxy python-api-consul
   IDn=`curl -s http://python-api-consul:5000/getval?key=mysqld/serverid --noproxy python-api-consul`
   curl -s "http://python-api-consul:5000/incval?key=mysqld/serverid" --noproxy python-api-consul

   echo " --------------------------------------"; 
   echo " ==> MASTER WILL USER SERVER_ID : $IDn";
   echo " --------------------------------------"; 
   
export SERVER_ID=$IDn
  cat >/docker-entrypoint-initdb.d/init-master.sh  <<'EOF'
#!/bin/bash
echo ---------------------------- 
echo Creating replication user ...
echo ---------------------------- 
mysql -u root -e "\
  GRANT \
    FILE, \
    SELECT, \
    SHOW VIEW, \
    LOCK TABLES, \
    RELOAD, \
    REPLICATION SLAVE, \
    REPLICATION CLIENT \
  ON *.* \
  TO '$REPLICATION_USER'@'%' \
  IDENTIFIED BY '$REPLICATION_PASSWORD'; \
  FLUSH PRIVILEGES; \
"
EOF
else
   # SERVER ID discovery
   IDn=`curl -s http://python-api-consul:5000/getval?key=mysqld/serverid --noproxy python-api-consul`
   curl -s "http://python-api-consul:5000/incval?key=mysqld/serverid" --noproxy python-api-consul

   echo " --------------------------------------"; 
   echo " ==> SLAVE WILL USER SERVER_ID : $IDn";
   echo " --------------------------------------"; 

  export SERVER_ID=$IDn
  cp -v /init-slave.sh /docker-entrypoint-initdb.d/
  cat > /etc/mysql/mysql.conf.d/repl-slave.cnf << EOF
[mysqld]
log-slave-updates
master-info-repository=TABLE
relay-log-info-repository=TABLE
relay-log-recovery=1
EOF
fi

cat > /etc/mysql/mysql.conf.d/server-id.cnf << EOF
[mysqld]
#server-id=$SERVER_ID
server-id=$IDn
EOF

exec docker-entrypoint.sh "$@"

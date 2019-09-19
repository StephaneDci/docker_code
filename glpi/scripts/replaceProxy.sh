#!/bin/bash

#
# Attention ce script ne doit pas être appelé en direct mais via un autre script dans bashrc: 
##
## proxy_auth="user:Pwd@ip:port/";
##
##
## alias proxyon="export http_proxy=http://$proxy_auth ; export https_proxy=https://$proxy_auth; env | grep proxy ; mv -f /etc/systemd/system/docker.service.d/http-proxy.conf.NO /etc/systemd/system/docker.service.d/http-proxy.conf ; ls /etc/systemd/system/docker.service.d/http-proxy.conf*; git config --global https.proxy \"https://$proxy_auth\" ; git config --global http.proxy \"http://$proxy_auth\"; sh /root/Docker/scripts/replaceProxy.sh ON"
##
## alias proxyoff='export https_proxy="" ; export http_proxy="" ; env | grep proxy ; mv -f /etc/systemd/system/docker.service.d/http-proxy.conf{,.NO} ; ls /etc/systemd/system/docker.service.d/http-proxy.conf*; git config --global https.proxy "" ; git config --global http.proxy "" ; sh /root/Docker/scripts/replaceProxy.sh OFF'
##
## alias docker-restart='systemctl daemon-reload ; service docker restart'



echo " ========================================================== ";
echo ""
echo "   Remplacement des Proxy dans les Dockerfile    ";
echo ""
echo " ========================================================== ";

if [ $# -ne 1 ] ; then
    echo "ERREUR : USAGE $0 <ON> | <OFF>";
    exit  2
fi


echo ""
echo "Configuring proxy to $1 ...";
echo ""
    for fic in `find /root/Docker -type f -name 'Dockerfile' -exec grep -il http_proxy {} \;` ; do
        echo "   Traitement de => $fic";

        # Remplacement de la valeur http_proxy par ce qui est exporté en var d'environnement
        sed -i "/ENV\ http_proxy/Ic\ENV http_proxy \"$http_proxy\""    $fic;
        sed -i "/ENV\ https_proxy/Ic\ENV https_proxy \"$https_proxy\"" $fic;

        # Traitement pour PIP et CONFD  et commentaire de "http(s)_proxy
        # ajout de "#" en debut de la ligne pour commenter le proxy dans les options de pip
        if [ $1 == "OFF" ] ; then 
            sed -i "/ENV\ PIP_OPTION/s/^/#/"   $fic
            sed -i "/ENV\ http_proxy/s/^/#/"   $fic;
            sed -i "/ENV\ https_proxy/s/^/#/"  $fic;
            sed -i "s#http://http-serv:6789/confd-0.15.0-linux-amd64#https://github.com/kelseyhightower/confd/releases/download/v0.15.0/confd-0.15.0-linux-amd64#g" $fic
        else 
        # Suppression des commentaires de 1 ou plusieurs "#" en debut de ligne
            sed -i "/ENV\ PIP_OPTION/s/#\{1,\}//"   $fic
            sed -i "/ENV\ http_proxy/s/#\{1,\}//"   $fic;
            sed -i "/ENV\ https_proxy/s/#\{1,\}//"  $fic;
            sed -i "s#https://github.com/kelseyhightower/confd/releases/download/v0.15.0/confd-0.15.0-linux-amd64#http://http-serv:6789/confd-0.15.0-linux-amd64#g" $fic
        fi

    done
echo ""
echo " DONE !"


#!/bin/bash
clear
echo ""
echo "==========================================================================================================="
echo "                                -------------------------------------"
echo "                                         HEALTHCHECK DOCKER"
echo "                                -------------------------------------"
echo "==========================================================================================================="
echo ""
echo '-----------------------------------------------------------------------------------------------------------'
echo ""
echo '======================================'
echo '  ##   DOCKER  HEALTH   ... ##'
echo '======================================'
echo ""
echo '    [+] Processus Docker actifs:'
echo '    ----------------------------'
docker ps
echo ""
echo ""
echo '    [+] Volumes Docker actifs:'
echo '    ----------------------------'
docker volume ls 
echo ""
echo '-----------------------------------------------------------------------------------------------------------'
echo ""
echo '======================================'
echo '  ##   MYSQL  HEALTH   ... ##'
echo '======================================'
echo ""
echo '   --------------'
echo '     * master *'
echo '   --------------'
echo ""
echo '    [+] docker exec mysql_master mysql glpi -e "SHOW MASTER STATUS\G;"'
docker exec mysql_master mysql glpi -e "SHOW MASTER STATUS\G;"
echo ""
echo '    [+] docker exec mysql_master mysql glpi -e "SELECT COUNT(*) FROM glpi_tickets;"'
docker exec mysql_master mysql glpi -e "SELECT COUNT(*) AS NB_TICKET_MASTER FROM glpi_tickets;"

for slave in `docker ps | grep mysql_slave | tr -s " " | cut -d " " -f1`; do
    echo ""
    echo '   -----------------------------'
    echo "     * slave : $slave *"
    echo '   -----------------------------'
    echo ""
    echo "    [+] docker exec $slave mysql glpi -e SELECT COUNT(*) FROM glpi_tickets;"
    docker exec $slave mysql glpi -e "SELECT COUNT(*) AS NB_TICKET_SLAVE FROM glpi_tickets;"
    echo ""
    echo "    [+] docker exec $slave  mysql glpi -e SHOW SLAVE STATUS\G;"
    docker exec $slave  mysql glpi -e "SHOW SLAVE STATUS\G;"
    echo ""
done

echo '-----------------------------------------------------------------------------------------------------------'
echo ""
echo '======================================'
echo '  ##   VARNISH  HEALTH   ...        ##'
echo '======================================'
echo ""
echo '    [+] docker exec varnish varnishstat -1 | grep -i cache'
docker exec varnish varnishstat -1 | grep -i cache
echo ""
echo '-----------------------------------------------------------------------------------------------------------'
echo ""
echo '======================================'
echo '  ##   NODEPHP  HEALTH   ... ##'
echo '======================================'
echo ""

for node in `docker ps | grep nodephp | tr -s " " | cut -d " " -f1`; do
echo ' ----------------------------'
echo "  * nodephp : $node *"
echo ' ----------------------------'
    echo ""
    echo "    [+] docker exec $node curl -Si 127.0.0.1/status.php --noproxy 127.0.0.1"
    echo ""
    docker exec $node curl -si 127.0.0.1/status.php --noproxy 127.0.0.1
done

echo '-----------------------------------------------------------------------------------------------------------'
echo ""
echo '======================================='
echo '  ##   CONSUL  HEALTH    ... ##'
echo '======================================='
echo ""
echo '    [+] curl -SI http://127.0.0.1:8500/v1/catalog/services'
echo ""
curl -SI http://127.0.0.1:8500/v1/catalog/services
echo ""
echo '    [+] curl -SI http://127.0.0.1:8500/v1/kv/php-apache/node/?keys'
echo ""
curl http://127.0.0.1:8500/v1/kv/php-apache/node/?keys
echo ""
echo '-----------------------------------------------------------------------------------------------------------'
echo ""
echo "==========================================================================================================="
echo ""
echo ""

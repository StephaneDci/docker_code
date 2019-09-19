#FROM        grafana/grafana:latest
FROM        grafana/grafana:latest
LABEL	    "DESCRIPTION"="######### GRAFANA CONTAINER #########"
MAINTAINER  Stephane 

ARG GF_INSTALL_PLUGINS="natel-plotly-panel,yesoreyeram-boomtable-panel,briangann-datatable-panel,natel-discrete-panel,michaeldmoore-multistat-panel,digrich-bubblechart-panel"

USER grafana

RUN if [ ! -z "${GF_INSTALL_PLUGINS}" ]; then \
    OLDIFS=$IFS; \
        IFS=','; \
    for plugin in ${GF_INSTALL_PLUGINS}; do \
        IFS=$OLDIFS; \
        grafana-cli --pluginsDir "$GF_PATHS_PLUGINS" plugins install ${plugin}; \
    done; \
fi
 
COPY  start.sh /start.sh
COPY  provisioning /etc/grafana/provisioning
COPY  grafana.ini   /etc/grafana/grafana.ini
COPY  dashboards   /var/lib/grafana/dashboards

ENTRYPOINT ["/start.sh"]

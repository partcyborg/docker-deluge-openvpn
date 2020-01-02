#!/bin/sh

# More/less taken from https://github.com/linuxserver/docker-baseimage-alpine/blob/3eb7146a55b7bff547905e0d3f71a26036448ae6/root/etc/cont-init.d/10-adduser

RUN_AS=root

if [ -n "$PUID" ] && [ ! "$(id -u root)" -eq "$PUID" ]; then
    RUN_AS=abc
    if [ ! "$(id -u ${RUN_AS})" -eq "$PUID" ]; then usermod -o -u "$PUID" ${RUN_AS} ; fi
    if [ ! "$(id -g ${RUN_AS})" -eq "$PGID" ]; then groupmod -o -g "$PGID" ${RUN_AS} ; fi

    if [ -n "$DISABLE_DATA_OWNERSHIP_CHANGE" ]; then
       echo "Ownership change for /data disabled"
    else
       echo "Setting ownership to ${PUID}:${PGID} and correct file/directory permissions for /data"
       chown -R ${RUN_AS}:${RUN_AS} /data 
    fi

    echo "Setting owner for other deluge paths to ${PUID}:${PGID}"
    chown -R ${RUN_AS}:${RUN_AS} \
        /config \
        ${DELUGE_HOME} \
        ${DELUGE_DOWNLOAD_DIR} \
        ${DELUGE_INCOMPLETE_DIR} \
        ${DELUGE_WATCH_DIR}
    
    if [ -n "$DISABLE_DATA_OWNERSHIP_CHANGE" ]; then
       echo "Permission change for /data disabled"
    else
       echo "Setting permission for files (644) and directories (755) in /data"
       chmod -R go=rX,u=rwX /data
    fi

    echo "Setting permission for files (644) and directories (755) in other deluge paths"
    chmod -R go=rX,u=rwX \
        /config \
        ${DELUGE_HOME} \
        ${DELUGE_DOWNLOAD_DIR} \
        ${DELUGE_INCOMPLETE_DIR} \
        ${DELUGE_WATCH_DIR}        
fi

echo "
-------------------------------------
Deluge will run as
-------------------------------------
User name:   ${RUN_AS}
User uid:    $(id -u ${RUN_AS})
User gid:    $(id -g ${RUN_AS})
-------------------------------------
"

export PUID
export PGID
export RUN_AS

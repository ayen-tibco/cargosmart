#!/bin/bash
# Copyright (c) 2017 TIBCO Software Inc.
#
COMPOSE_VERSION=1.9.0
COMPOSE_INSTALL_PATH=/usr/local/bin
COMPOSE_SRC_URL=https://github.com/docker/compose/releases/download
if [ ! -f $COMPOSE_INSTALL_PATH/docker-compose ]; then
    curl -L $COMPOSE_SRC_URL/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > $COMPOSE_INSTALL_PATH/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

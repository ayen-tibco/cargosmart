#!/bin/bash
# Copyright (c) 2017 TIBCO Software Inc.
#
INSTALL_PATH=${DOCKER_COMPOSE_INSTALL_PATH}

if [ -z "$INSTALL_PATH" ]; then
    INSTALL_PATH=/usr/local/bin
fi

curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" -o /tmp/docker-compose &&
    chmod +x /tmp/docker-compose &&
    sudo cp /tmp/docker-compose $INSTALL_PATH/docker-compose

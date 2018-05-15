#!/bin/bash
# Copyright (c) 2017 TIBCO Software Inc.
#
INSTALL_PATH=${DOCKER_MACHINE_INSTALL_PATH}

if [ -z "$INSTALL_PATH" ]; then
    INSTALL_PATH=/usr/local/bin
fi

curl -L https://github.com/docker/machine/releases/download/v0.9.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
    chmod +x /tmp/docker-machine &&
    sudo cp /tmp/docker-machine $INSTALL_PATH/docker-machine

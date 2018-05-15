#!/bin/bash
# Copyright (c) 2017 TIBCO Software Inc.
#
set -x
if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters"
    echo "docker_machine_sync.sh /src_dir <docker-machine_nodename1> <docker_machine_nodename2> ..."
    exit 1
fi
DOCKERMACHINE=${DOCKER_MACHINE_INSTALL_PATH}/docker-machine
SRC_DIR=$1
# default host target directory
TARGET_DIR=/docker-machine
shift
while [ "$1" != "" ]; do
    $DOCKERMACHINE ssh $1 sudo mkdir /docker-machine
    $DOCKERMACHINE ssh $1 sudo chmod -R go+rwx $TARGET_DIR
    $DOCKERMACHINE scp -r $SRC_DIR $1:$TARGET_DIR
    shift
done

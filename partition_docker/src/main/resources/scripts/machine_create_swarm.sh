#!/bin/bash
# Copyright (c) 2017 TIBCO Software Inc.
#
# Create classic legacy swarm cluster using docker-machine
set -x
if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters"
    echo "machine_create_swarm.sh <swarm_manager_nodename> <swarm_worker_nodename1> <swarm_worker_nodename2> ..."
    exit 1
fi
 
SWARM_MANAGER=$1
DOCKERMACHINE=${DOCKER_MACHINE_INSTALL_PATH}/docker-machine

# create the key/value store server - here we use consul
$DOCKERMACHINE create -d ${DOCKER_MACHINE_DRIVER} ${DOCKER_INSECURE_REGISTRY} ${DOCKER_KVSTORE}
if [ $? -eq 0 ]; then
    eval $($DOCKERMACHINE env ${DOCKER_KVSTORE})
    docker run --name consul --restart=always -p 8400:8400 -p 8500:8500 \
  -p 53:53/udp -d progrium/consul -server -bootstrap-expect 1 -ui-dir /ui
else
    echo "Failed to create kvstore consul server."
    exit 1
fi

# create swarm manager
$DOCKERMACHINE create -d ${DOCKER_MACHINE_DRIVER} ${DOCKER_INSECURE_REGISTRY} --swarm --swarm-master \
  --swarm-discovery="consul://$($DOCKERMACHINE ip ${DOCKER_KVSTORE}):8500" \
  --engine-opt="cluster-store=consul://$($DOCKERMACHINE ip ${DOCKER_KVSTORE}):8500" \
  --engine-opt="cluster-advertise=eth0:2376" $SWARM_MANAGER

if [ $? -eq 0 ]; then
    # create swarm workers 
    shift
    while [ "$1" != "" ]; do
        SWARM_WORKER=$1
        $DOCKERMACHINE create -d ${DOCKER_MACHINE_DRIVER} ${DOCKER_INSECURE_REGISTRY} --swarm \
  --swarm-discovery="consul://$($DOCKERMACHINE ip ${DOCKER_KVSTORE}):8500" \
  --engine-opt="cluster-store=consul://$($DOCKERMACHINE ip ${DOCKER_KVSTORE}):8500" \
  --engine-opt="cluster-advertise=eth0:2376" $SWARM_WORKER
        if [ $? -ne 0 ]; then
            echo "Failed to create swarm worker $SWARM_WORKER."
            exit 1
        else
            shift
        fi
    done
else
    echo "Failed to create swarm manager $SWARM_MANAGER."
    exit 1
fi

$DOCKERMACHINE ls
exit $?

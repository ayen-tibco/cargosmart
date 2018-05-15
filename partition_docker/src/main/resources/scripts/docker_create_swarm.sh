#!/bin/bash
# Copyright (c) 2017 TIBCO Software Inc.
#
# Create swarm manager and worker using docker swarm mode
# FIX THIS -A.Y.-docker overlay driver does not provide udp broadcast and weave driver plugin is broken in Docker 1.13.0
set -x
if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters"
    echo "docker_init_swarm.sh <swarm_manager_nodename> <swarm_worker_nodename1> <swarm_worker_nodename2> ..."
    exit 1
fi
DOCKERMACHINE=${DOCKER_MACHINE_INSTALL_PATH}/docker-machine 
SWARM_MANAGER=$1
SWARM_MANAGER_IP=`$DOCKERMACHINE ip $SWARM_MANAGER`

eval $($DOCKERMACHINE env $SWARM_MANAGER)
docker swarm init --advertise-addr $SWARM_MANAGER_IP


if [ $? -eq 0 ]; then
    # get swarm token
    SWARM_MANAGER_TOKEN=`docker swarm join-token -q manager`

    # join workers
    while [ "$1" != "" ]; do
        SWARM_WORKER=$1
        echo "Joining swarm worker $SWARM_WORKER with manager $SWARM_MANAGER..."
        eval $($DOCKERMACHINE env $SWARM_WORKER)
        docker swarm join --token $SWARM_MANAGER_TOKEN $SWARM_MANAGER_IP:2377
        # Shift all the parameters down by one
        shift
    done
else
    echo "failed initializing swarm manager"
fi

docker node ls
exit $?

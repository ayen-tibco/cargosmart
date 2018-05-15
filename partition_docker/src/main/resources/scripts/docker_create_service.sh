#!/bin/bash
# Copyright (c) 2017 TIBCO Software Inc.
#
# create docker service in two nodes swarm mode
set -x
DOCKERMACHINE=${DOCKER_MACHINE_INSTALL_PATH}/docker-machine
SWARM_MANAGER=$1
SWARM_MANAGER_IP=`$DOCKERMACHINE ip $SWARM_MANAGER`
WEAVE=${WEAVE_INSTALL_PATH}/weave
DOCKER_ENVFILE=${DOCKER_ENVFILE}
echo $SWARM_MANAGER_IP >./SWARM_MANAGER_IP.txt

eval $($DOCKERMACHINE env --swarm $SWARM_MANAGER)
eval "$($WEAVE env)"

docker-compose -f ${project.build.directory}/staging/docker/${DOCKER_COMPOSE_FILE} up -d
fifo=/tmp/tmpfifo.$$
mkfifo "${fifo}" || exit 1
docker-compose -f ${project.build.directory}/staging/docker/${DOCKER_COMPOSE_FILE} logs -f 2>&1 | tee ${fifo} &
logpid=$!
grep -m 1 "Node started" "${fifo}"
kill "${logpid}"
rm "${fifo}"

#docker service create --name A1 --mode global --mount type=bind,src=/docker-machine,dst=/docker-machine -e NODENAME=${A1_NODENAME} --env-file $DOCKER_ENVFILE --hostname ${A1_NODENAME} --network weave -p 5556:5556 --constraint 'node.hostname==${nodename1}' $SB_DOCKER_IMAGE
#docker service create --name A2 --mode global --mount type=bind,src=/docker-machine,dst=/docker-machine -e NODENAME=${A2_NODENAME} --env-file $DOCKER_ENVFILE --hostname ${A2_NODENAME} --network weave --constraint 'node.hostname==${nodename2}' $SB_DOCKER_IMAGE
#docker service ls


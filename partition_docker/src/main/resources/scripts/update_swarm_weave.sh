#!/bin/bash -x
# Copyright (c) 2017 TIBCO Software Inc.
#
if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters"
    echo "update_swarm_weave.sh <swarm_manager_nodename> <swarm_worker_nodename1> <swarm_worker_nodename2> ..."
    exit 1
fi
DOCKERMACHINE=${DOCKER_MACHINE_INSTALL_PATH}/docker-machine
# save the line argument for reprocessing for updating swarm
ARGS=$@

SWARM_MANAGER=$1
SWARM_MANAGER_IP=`$DOCKERMACHINE ip $SWARM_MANAGER`
WEAVE=${WEAVE_INSTALL_PATH}/weave
# FIX This - A.Y. use weave for now until network plugin driver is working in docker swarm mode
curl -L git.io/weave -o $WEAVE
chmod a+x $WEAVE
#docker network create --driver overlay isolated_nw
eval "$($DOCKERMACHINE env $SWARM_MANAGER)"
$WEAVE launch --dns-domain=${CLUSTERNAME}.local.

if [ $? -eq 0 ]; then
    # create weavenet on swarm workers
    shift
    while [ "$1" != "" ]; do
        SWARM_WORKER=$1
        eval "$($DOCKERMACHINE env $SWARM_WORKER)"
        $WEAVE launch --dns-domain=${CLUSTERNAME}.local. $SWARM_MANAGER_IP
        $WEAVE connect $SWARM_MANAGER_IP
        shift
    done
else
    echo "failed creating Weave primary peer."
    exit 1
fi

$WEAVE status

swarm_discovery_token="consul://$($DOCKERMACHINE ip ${DOCKER_KVSTORE}):8500"

set -- $ARGS
while [ "$1" != "" ]; do
  SWARM_NODE=$1
  ## We are not really using Weave script anymore, hence
  ## this is only a local variable
  DOCKER_CLIENT_ARGS="$($DOCKERMACHINE config $SWARM_NODE)"

  ## Default Weave proxy port is 12375
  weave_proxy_endpoint="$($DOCKERMACHINE ip $SWARM_NODE):12375"

  ## Next, we restart the slave agents
  docker ${DOCKER_CLIENT_ARGS} rm -f swarm-agent
  docker ${DOCKER_CLIENT_ARGS} run \
    -d \
    --restart=always \
    --name=swarm-agent \
    swarm join \
    --addr "${weave_proxy_endpoint}" \
    "${swarm_discovery_token}"

  if [ "$SWARM_NODE" == "$SWARM_MANAGER" ] ; then
    ## On the head node we will also restart the master
    ## with the new token and all the original arguments; the reason
    ## this is a bit complicated is because we need steal all the
    ## `--tls*` arguments as well as the `-v` ones
    swarm_master_args_fmt="\
      -d \
      --restart=always \
      --name={{.Name}} \
      -p 3376:3376 \
      {{range .HostConfig.Binds}}-v {{.}} {{end}} \
      swarm{{range .Args}} {{.}}{{end}} \
    "
    swarm_master_args=$(docker ${DOCKER_CLIENT_ARGS} inspect \
        --format="${swarm_master_args_fmt}" \
        swarm-agent-master \
        | sed "s|\(token://\)[[:alnum:]]*|\1${swarm_discovery_token}|")

    docker ${DOCKER_CLIENT_ARGS} rm -f swarm-agent-master
    docker ${DOCKER_CLIENT_ARGS} run ${swarm_master_args}
  fi
  shift
done

# pause to let swarm master sync up with the workers
sleep 10
docker $($DOCKERMACHINE config -swarm $SWARM_MANAGER) info
exit $?

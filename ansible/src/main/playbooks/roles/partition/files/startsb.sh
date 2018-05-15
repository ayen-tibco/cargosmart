#!/bin/bash
# Copyright (c) 2017 TIBCO Software Inc.
#
# Docker Container Script to startup StreamBase
# Provides pre-flight node directory deployment cleanup before and after shutdown.
# Assumes ENV variables STREAMBASE_HOME, JAVA_HOME, ans SW_HOME set in container already.
# When stopping container, give -t 30 grace timeout before killing the entire container
# Example: 
#
#  docker run -d --name node1 --hostname=node1 -P docker.tibco.com/ep/sb_helloworld:rhel7latest
#  docker run -d --name node2 --hostname=node2 -P docker.tibco.com/ep/sb_helloworld:rhel7latest
#  ./update-docker-dns.sh
#
#  docker stop -t 30 node1
#  docker start node1
#
set -x
sleep 5
ADMINISTRATOR=$TIBCO_EP_HOME/distrib/tibco/bin/epadmin
NODE_INSTALL_DIR=${NODE_INSTALL_DIR}
export _JAVA_OPTIONS=-DSW_HOME=$SW_HOME
DOMAIN_NAME=`domainname -d`

# check if Cluster is present
if [ ! -z "$1" ]; then
  ClusterName=$1
else
  DOMAIN_NAME=`domainname -d`
  if [ ! -z "$DOMAIN_NAME" ]; then
    ClusterName=$DOMAIN_NAME
  else
    ClusterName=Cluster1
  fi
fi


# if node config is present, set the parameter with location of the config file
if [ ! -z "$NODE_CONFIG" ]; then
	NODE_CONFIG="nodedeploy=$SB_APP_DIR/$NODE_CONFIG"
fi

# if nodename is not present, need to set it - append Cluster Name at the end
if [ ! -z "$NODENAME" ]; then
    NODE_NAME="nodename=$NODENAME"
else
  if [ -z "$DOMAIN_NAME" ]; then
    NODENAME=$HOSTNAME.$ClusterName
  else
    NODENAME=$HOSTNAME
  fi
    NODE_NAME="nodename=$NODENAME"
fi

if [ ! -z "$SB_APP_FILE" ]; then
    SB_APP_FILE="application=$SB_APP_DIR/$SB_APP_FILE"
fi

if [ ! -z "$SB_ADMIN_PORT" ]; then
    ADMIN_PORT="adminport=$SB_ADMIN_PORT"
fi

if [ ! -z "$SUBSTITUTIONS" ]; then
    SUBSTITUTIONS=substitutions="$SUBSTITUTIONS"
fi

if [ -z "$BUILDTYPE" ]; then
    BUILDTYPE=PRODUCTION
fi

if [ ! -z "$2" ]; then
  APPLIB_PATH=$2
else
  APPLIB_PATH=$STREAMBASE_HOME/lib
fi

if [ ! -d "$NODE_INSTALL_DIR" ]; then
	mkdir -p $NODE_INSTALL_DIR
else
	#clean host config directories in case there was a abrupt shutdown
	$ADMINISTRATOR remove node installpath=$NODE_INSTALL_DIR/$NODENAME
	rm -rf $NODE_INSTALL_DIR/*
fi

sleep 5
# use weave ip address to do discovery
WEAVE_HOSTNAME=`echo $TUTUM_IP_ADDRESS | sed 's/\/16//'`

if [ -z "$WEAVE_HOSTNAME" ]; then
    DISCOVERYHOSTS=
else
    DISCOVERYHOSTS=discoveryhosts=$WEAVE_HOSTNAME
fi

# Install node A in cluster X - administration port set to 5556
$ADMINISTRATOR install node $DISCOVERYHOSTS nodedirectory=$NODE_INSTALL_DIR $ADMIN_PORT $NODE_NAME $SB_APP_FILE $NODE_CONFIG $SUBSTITUTIONS deploydirectories=$APPLIB_PATH:$SB_APP_DIR:$SB_APP_DIR/java-bin buildtype=$BUILDTYPE


# throwing in trap/wait to capture docker stop SIGTERM/INT signals
#Start the node using the assigned administration port
$ADMINISTRATOR servicename=$NODENAME start node

sleep 5


if [ "$container" == "docker" ]; then

    sleep 5
    trap "echo Docker stop requested ; break" TERM INT

    while true
    do
        echo 'To Quit/Stop: CTRL+c. To Detach from docker Console: CTRL+p + CTRL+q.'
        sleep 300 &
        trap "echo Docker stop requested ; break" TERM INT
        wait $PID
        EXIT_STATUS=$?   
    done

    # Cleanup: Stop and Remove SB after - need at least 30 seconds before container exits entirely
    $ADMINISTRATOR servicename=$NODENAME stop node
    $ADMINISTRATOR remove node installpath=$NODE_INSTALL_DIR/$NODENAME
fi

#!/bin/bash
# Copyright (c) 2017 TIBCO Software Inc.
#
# Docker Container Script to startup SB10
# Provides pre-flight node directory deployment cleanup before and after shutdown.
# Assumes ENV variables JAVA_HOME, TIBCO_EP_HOME, etc. set in image or docker run.
#
# Example: 
#
#  docker run -d --name A1.topologies --hostname=A1.topologies -P ep/docker:latest
#  docker run -d --name A2.topologies --hostname=A2.topologies -P ep/docker:latest
#
#
#  docker stop node1
#  docker start node1
#
set -x
sleep 5
# try to guess default locations for epadmin
if [ -z "$ADMINISTRATOR" ]; then
    ADMINISTRATOR=$TIBCO_EP_HOME/distrib/tibco/bin/epadmin
fi

# try to guess default locations for deploy node path
if [ -z "$NODE_INSTALL_PATH" ]; then
    NODE_INSTALL_PATH=$TIBCO_EP_HOME/deploy/nodes
fi


export _JAVA_OPTIONS=-DTIBCO_EP_HOME=$TIBCO_EP_HOME
DOMAIN_NAME=`domainname -d`

# check if Cluster is present
if [ -z "$ClusterName" ]; then

  if [ -z "$1" ]; then
    ClusterName=$1
  else
    DOMAIN_NAME=`domainname -d`
    if [ ! -z "$DOMAIN_NAME" ]; then
      ClusterName=$DOMAIN_NAME
    else
      ClusterName=Cluster1
    fi
  fi
fi


# if node config is present, ignore nodename parameter
if [ ! -z "$NODE_CONFIG" ]; then
	NODE_CONFIG="nodedeploy=$SB_APP_DIR/$NODE_CONFIG"
fi

# check if nodename is present
if [ ! -z "$NODENAME" ]; then
    NODE_NAME="nodename=$NODENAME"
else
  if [ -z "$DOMAIN_NAME" ]; then
    NODENAME=$HOSTNAME.$ClusterName
  else
    if `echo $HOSTNAME | grep -q $DOMAIN_NAME` ; then
        NODENAME=$HOSTNAME
    else
        NODENAME=$HOSTNAME.$DOMAIN_NAME
    fi
  fi
    NODE_NAME="nodename=$NODENAME"
fi

if [ ! -z "$SB_APP_FILE" ]; then
    SB_APP_FILE="application=$SB_APP_DIR/$SB_APP_FILE"
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

if [ ! -d "$NODE_INSTALL_PATH" ]; then
	mkdir -p $NODE_INSTALL_PATH
else
	#clean host config directories in case there was a abrupt shutdown
	$ADMINISTRATOR remove node installpath=$NODE_INSTALL_PATH/$NODENAME
	rm -rf $NODE_INSTALL_PATH/*
fi

if [ -z "$WEAVE_HOSTNAME" ]; then
    DISCOVERYHOSTS=
else
    DISCOVERYHOSTS=discoveryhosts=$WEAVE_HOSTNAME
fi

if [ -z "$EPUSERNAME" ]; then
    EPUSERNAME=guest
    EPPASSWD=guest
fi

# Install node A in cluster X - administration port set to 5556
$ADMINISTRATOR username=$EPUSERNAME password=$EPPASSWD install node $DISCOVERYHOSTS nodedirectory=$NODE_INSTALL_PATH adminport=5556 $NODE_NAME $SB_APP_FILE $NODE_CONFIG $SUBSTITUTIONS deploydirectories=$APPLIB_PATH:$SB_APP_DIR buildtype=$BUILDTYPE
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "Failed INSTALLING node, error code is ${exit_code}. Shutting down container..."
    exit $exit_code
else
    #Start the node using servicename/nodename which supports both static and dynamic
    $ADMINISTRATOR servicename=$NODENAME start node
    exit_code=$?
    #Start the node using local hostname if servicename fails above
    if [ $exit_code -gt 0 ]; then
        $ADMINISTRATOR adminport=5556 start node
        exit_code=$?
    fi

    if [ $exit_code -eq 0 ]; then
        if [ "$STOP_FOREGROUND" == "true" ];then 
            echo "STOP_FOREGROUND variable set after start node completed successfully. Exiting docker container...."
            exit $exit_code
        fi
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
        $ADMINISTRATOR adminport=5556 stop node
        $ADMINISTRATOR remove node installpath=$NODE_INSTALL_PATH/$NODENAME
    else 
        echo "Failed STARTING node, error code is ${exit_code}. Shutting down container..."
        exit $exit_code
    fi
fi


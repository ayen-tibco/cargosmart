#!/bin/bash
# Copyright (c) 2017 TIBCO Software Inc.
#
# docker 1.9+ required - works on OS X as well

# remove exited containers:
docker ps --filter status=dead --filter status=exited -aq | xargs docker rm -v
    
# remove unused images:
docker images --no-trunc | grep '<none>' | awk '{ print $3 }' | xargs docker rmi

# remove unused volumes:
docker volume ls -qf dangling=true | xargs docker volume rm
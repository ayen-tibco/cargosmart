# Copyright (c) 2017 TIBCO Software Inc.
#
set -x
docker tag $SB_DOCKER_IMAGE $SB_REMOTE_DOCKER_IMAGE
if [ -n "$DOCKER_REGISTRY_PASSWORD" ]; then
    docker login -u $DOCKER_REGISTRY_USERNAME -p $DOCKER_REGISTRY_PASSWORD
fi
docker push $SB_REMOTE_DOCKER_IMAGE

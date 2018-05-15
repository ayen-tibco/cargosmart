#!/bin/bash
set -x
docker network create oocl
docker run -d --rm --name A.partition_docker_test --hostname A.partition_docker_test -e NODENAME=A.partition_docker_test -p 10000:10000 --network oocl dtmexamples/partition_docker_test
docker run -d --rm --name B.partition_docker_test --hostname B.partition_docker_test -e NODENAME=B.partition_docker_test --network oocl dtmexamples/partition_docker_test
docker run -d --rm --name C.partition_docker_test --hostname C.partition_docker_test -e NODENAME=C.partition_docker_test --network oocl dtmexamples/partition_docker_test

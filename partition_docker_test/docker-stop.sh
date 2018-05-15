#!/bin/bash
set -x
containers="A.partition_docker_test B.partition_docker_test C.partition_docker_test"
for container in $containers; do
	docker stop $container
done
docker network rm oocl

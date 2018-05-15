#!/bin/bash
set -x
containers="A.partition B.partition C.partition"
for container in $containers; do
	docker stop $container
done
docker network rm oocl

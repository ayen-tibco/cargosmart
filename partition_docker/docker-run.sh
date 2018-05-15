#!/bin/bash
set -x
docker network create oocl
docker run -d --rm --name A.partition --hostname A.partition --env-file ./partition.env --network oocl oocl:latest
docker run -d --rm --name B.partition --hostname B.partition --env-file ./partition.env --network oocl oocl:latest
docker run -d --rm --name C.partition --hostname C.partition --env-file ./partition.env --network oocl oocl:latest

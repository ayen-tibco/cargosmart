#!/bin/bash
RESULT=$(docker ps -q -f "name=registry" -f "status=running")
if [ "$RESULT" == "" ]; then
	docker run -d -p 5000:5000 --restart=always --name registry registry:2
fi

#!/bin/sh

docker exec -it $(docker ps | grep node1_app_1 | awk '{print $1}') bin/node1 remote_console

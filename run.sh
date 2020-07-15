#!/bin/sh

docker stop zookeeper
docker rm zookeeper

docker run -d \
    -p 2181:2181 \
    -p 2888:2888 \
    -p 3888:3888 \
    --name zookeeper fransking/zookeeper:3.4.14-arm32v7

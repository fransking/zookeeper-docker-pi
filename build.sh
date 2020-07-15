#!/bin/bash

docker build -t fransking/zookeeper:3.4.14-arm32v7 .
docker image inspect fransking/zookeeper:3.4.14-arm32v7 --format='{{.Size}}'

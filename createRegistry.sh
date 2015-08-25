#!/bin/bash
set -e
REGISTRY_IMAGE_NAME=${REGISTRY:-registry}

docker run \
--name ${REGISTRY_IMAGE_NAME} \
-p 5000:5000 \
-v /opt/docker-registry:/tmp/registry \
-d ${REGISTRY_IMAGE_NAME}

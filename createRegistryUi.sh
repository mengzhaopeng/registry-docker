#!/bin/bash
set -e
UI_NAME=${UI_NAME:-dockerui}
UI_IMAGE_NAME=${UI_IMAGE_NAME:-atcol/docker-registry-ui}

docker run \
--name ${UI_NAME} \
-p 8080:8080 \
-e APP_CONTEXT=dockerui \
-e READ_ONLY=true \
-e REG1=http://$HOSTNAME:5000/v1/ \
-d ${UI_IMAGE_NAME}

#!/bin/bash -e

echo $GCP_AUTH_KEY | base64 -d - > ${HOME}/gcp-key.json
export GOOGLE_APPLICATION_CREDENTIALS=${HOME}/gcp-key.json

for i in $(gsutil ls ${HELM_GS_BUCKET} | awk -F'/' '{ print $4 }')
do
	helm repo add ${i} ${HELM_GS_BUCKET}$i
done

#!/bin/bash -e

if [[ -f ".circleci/debuglog" ]]; then
	set -x
fi

echo $GCP_AUTH_KEY | base64 -d - > ${HOME}/gcp-key.json
export GOOGLE_APPLICATION_CREDENTIALS=${HOME}/gcp-key.json

gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS

for i in $(gsutil ls ${HELM_GS_BUCKET} | awk -F'/' '{ print $4 }')
do
	helm repo add ${i} ${HELM_GS_BUCKET}$i
done

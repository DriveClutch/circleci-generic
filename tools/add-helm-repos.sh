#!/bin/sh

for i in $(gsutil ls ${HELM_GS_BUCKET} | awk -F'/' '{ print $4 }')
do
	helm repo add ${i} ${HELM_GS_BUCKET}$i
done

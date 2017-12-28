#!/bin/bash -e

if [[ -f ".circleci/debuglog" ]]; then
	set -x
fi

if [[ ! -d ".helm" ]]; then
	echo "Helm directory does not exist, skipping packaging"
	exit 0
fi

echo $GCP_AUTH_KEY | base64 -d - > ${HOME}/gcp-key.json
export GOOGLE_APPLICATION_CREDENTIALS=${HOME}/gcp-key.json

REPONAME="${CIRCLE_PROJECT_REPONAME}-${CIRCLE_BRANCH}"
REPOLOCATION="${HELM_GS_BUCKET}${REPONAME}"

echo "Check if the repo is initialized"
set +e # Turn off failure dumping

helm repo add $REPONAME $REPOLOCATION
RET=$?
if [ "$RET" != "0" ]; then
	echo "$REPONAME was not initialized at $REPOLOCATION, performing bucket initialization"
	helm gcs init $REPOLOCATION
fi

set -e # Turn on failure dumping

echo "Adding $REPONAME repo to helm"
helm repo add $REPONAME $REPOLOCATION

cd .helm

GITHASHLONG=$(git rev-parse HEAD)
GITHASHSHORT=$(git rev-parse --short HEAD)
DT=$(date "+%Y%m%d.%H%M.%S")
PKGVER="${DT}"

for chartpath in */Chart.yaml
do
	pkgname=$(basename $(dirname $chartpath))
	grep -Ev "^appVersion:" ${chartpath} > ${chartpath}.new
	echo "appVersion: ${GITHASHLONG}" >> ${chartpath}.new
	mv ${chartpath}.new ${chartpath}

	# Update chart deps, set the chart version, (soon appVersion will be set here too)
	helm package --dependency-update --version=$PKGVER $pkgname
	helm gcs push ./${pkgname}-${PKGVER}.tgz $REPONAME
done

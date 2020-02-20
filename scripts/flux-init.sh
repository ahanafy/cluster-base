#!/usr/bin/env bash

set -e

if [[ ! -x "$(command -v kubectl)" ]]; then
    echo "kubectl not found"
    exit 1
fi

if [[ ! -x "$(command -v helm)" ]]; then
    echo "helm not found"
    exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
# HTTPS git.url format
REPO_URL='https://github.com/ahanafy/cluster-base.git'
# SSH git.url format
# REPO_URL=${1:-git@github.com:stefanprodan/gitops-istio}
REPO_BRANCH='cleanup'
REPO_PUBLIC=true
TEMP=${REPO_ROOT}/temp

rm -rf ${TEMP} && mkdir ${TEMP}

echo ">>> Creating Flux Namespace"
kubectl apply -f ${REPO_ROOT}/base/fluxcd/namespace.yaml

helm repo add fluxcd https://charts.fluxcd.io

echo ">>> Installing Flux for ${REPO_URL}"
helm upgrade -i fluxcd fluxcd/flux --wait --cleanup-on-fail \
--set git.url=${REPO_URL} \
--set git.branch=${REPO_BRANCH} \
--set git.pollInterval=1m \
--set git.readonly=${REPO_PUBLIC} \
--set registry.pollInterval=1m \
--namespace fluxcd

cat <<EOF >> ${TEMP}/repositories.yaml
configureRepositories:
  enable: true
  volumeName: repositories-yaml
  secretName: flux-helm-repositories
  cacheVolumeName: repositories-cache
  repositories:
    - caFile: ""
      cache: stable-index.yaml
      certFile: ""
      keyFile: ""
      name: stable
      password: ""
      url: https://kubernetes-charts.storage.googleapis.com
      username: ""
    - caFile: ""
      cache: istio.io-index.yaml
      certFile: ""
      keyFile: ""
      name: istio.io
      password: ""
      url: https://storage.googleapis.com/istio-release/releases/1.4.3/charts
      username: ""
    - caFile: ""
      cache: flagger-index.yaml
      certFile: ""
      keyFile: ""
      name: flagger
      password: ""
      url: https://flagger.app
      username: ""
EOF

echo ">>> Installing Helm Operator"
helm upgrade -i helm-operator fluxcd/helm-operator --wait --cleanup-on-fail \
--set git.ssh.secretName=fluxcd-git-deploy \
--set helm.versions=v3 \
-f ${TEMP}/repositories.yaml \
--namespace fluxcd

echo '>>> GitHub deploy key'
kubectl -n fluxcd logs deployment/flux | grep identity.pub | cut -d '"' -f2
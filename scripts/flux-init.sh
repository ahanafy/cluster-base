#!/usr/bin/env bash

set -e

if [[ ! -x "$(command -v kubectl)" ]]; then
    echo "kubectl not found"
    echo ">>> download the latest from here: https://kubernetes.io/docs/tasks/tools/install-kubectl/"
    exit 1
fi

if [[ ! -x "$(command -v helm)" ]]; then
    echo "helm not found"
    echo ">>> download the latest from here: https://github.com/helm/helm/releases"
    exit 1
fi

if [[ ! -x "$(command -v kubeseal)" ]]; then
    echo "kubeseal not found"
    echo ">>> download the latest from here: https://github.com/bitnami-labs/sealed-secrets/releases"
    exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
# HTTPS git.url format
REPO_URL=${1:-https://github.com/ahanafy/cluster-base.git}
# SSH git.url format
# REPO_URL=${1:-git@github.com:stefanprodan/gitops-istio}
REPO_BRANCH='master'
REPO_PUBLIC=true

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

echo ">>> Installing Helm Operator"
helm upgrade -i helm-operator fluxcd/helm-operator --wait --cleanup-on-fail \
--set git.ssh.secretName=fluxcd-git-deploy \
--set helm.versions=v3 \
-f ${REPO_ROOT}/base/fluxcd/repositories-configmap.yaml \
--namespace fluxcd

echo '>>> GitHub deploy key'
kubectl -n fluxcd logs deployment/fluxcd | grep identity.pub | cut -d '"' -f2
#!/usr/bin/env bash

# REPO_ROOT=$(git rev-parse --show-toplevel)

# kubectl delete -f ${REPO_ROOT}/istio-system/

# kubectl delete ns istio-system
# kubectl delete ns prod

# kubectl delete crd canaries.flagger.app

helm delete flux -n fluxcd
helm delete helm-operator -n fluxcd

kubectl delete -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/flux-helm-release-crd.yaml
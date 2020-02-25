#!/usr/bin/env bash

# REPO_ROOT=$(git rev-parse --show-toplevel)

# kubectl delete -f ${REPO_ROOT}/istio-system/

# kubectl delete ns istio-system
# kubectl delete ns prod

# kubectl delete crd canaries.flagger.app

helm delete fluxcd -n fluxcd
helm delete helm-operator -n fluxcd
helm delete sealed-secrets -n kube-system

kubectl delete ns fluxcd
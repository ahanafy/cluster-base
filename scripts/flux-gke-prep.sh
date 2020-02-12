#!/usr/bin/env bash

set -e

kubectl create clusterrolebinding "cluster-admin-flux" \
    --clusterrole=cluster-admin \
    --user="$(gcloud config get-value core/account)"
#!/usr/bin/env bash
kubectl delete deploy/fluxcd -n fluxcd

kubectl get hr --no-headers=true --all-namespaces | xargs -L1 bash -c 'kubectl delete -n $0 hr $1'

kubectl delete ns fluxcd

kubectl get sealedsecrets --no-headers=true --all-namespaces | xargs -L1 bash -c 'kubectl delete -n $0 sealedsecret $1'

kubectl delete secret/sealed-secrets-key -n kube-system

kubectl delete ns --selector='fluxcd.io/sync-gc-mark'
kubectl delete ns,gw,vs,policy,dr --selector='fluxcd.io/sync-gc-mark' --all-namespaces

kubectl get crd | grep 'flux\|weave' | xargs -L1 bash -c 'kubectl delete crd/$0'

kubectl get clusterrole --selector=heritage=Helm --no-headers=true| xargs -L1 bash -c 'kubectl delete clusterrole/$0'
kubectl delete clusterrole/istio-reader
kubectl delete clusterrole/istio-init-istio-system
kubectl delete clusterrolebinding/istio-init-admin-role-binding-istio-system
kubectl delete clusterrolebinding/istio-multi
kubectl delete MutatingWebhookConfiguration/istio-sidecar-injector
kubectl get clusterrolebinding --selector=heritage=Helm --no-headers=true | xargs -L1 bash -c 'kubectl delete clusterrolebinding/$0'
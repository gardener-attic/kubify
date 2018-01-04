#!/bin/bash -e

source "$(dirname "$0")"/source_me

for f in kube-system-rbac-role-binding kube-proxy kube-dns-svc kube-dns-deployment kube-flannel-rbac kube-flannel-cfg kube-flannel pod-checkpointer; do
  kubectl create -f /opt/bootkube/assets/manifests/$f.yaml || true
done
kubectl create -f /opt/bootkube/assets/etcd/bootstrap-etcd-service.json

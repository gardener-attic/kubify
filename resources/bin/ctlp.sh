#!/bin/bash -e

source "$(dirname "$0")"/source_me

for f in kube-apiserver-secret kube-apiserver kube-controller-manager-disruption kube-controller-manager-secret kube-controller-manager kube-scheduler-disruption kube-scheduler; do
  kubectl create -f /opt/bootkube/assets/manifests/$f.yaml || true
done

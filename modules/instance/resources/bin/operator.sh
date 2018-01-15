#!/bin/bash -e

source "$(dirname "$0")"/source_me
for f in etcd-client-tls etcd-peer-tls etcd-server-tls etcd-service etcd-operator; do
  kubectl create -f /opt/bootkube/assets/manifests/$f.yaml || true
done

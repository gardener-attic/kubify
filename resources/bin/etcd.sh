#!/bin/bash -e

source "$(dirname "$0")"/source_me
kubectl create -f /opt/bootkube/assets/etcd/migrate-etcd-cluster.json

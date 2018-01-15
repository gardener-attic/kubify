#!/bin/bash -e

mkdir -p /etc/kubernetes/bootstrap-secrets
cp -r /opt/bootkube/assets/tls/. /etc/kubernetes/bootstrap-secrets/.

mkdir -p /etc/kubernetes/manifests/
cp -r /opt/bootkube/assets/bootstrap-manifests/* /etc/kubernetes/manifests/





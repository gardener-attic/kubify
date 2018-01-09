#!/bin/bash
# Render the latest bootkube templates and replace the old one in this directory.

BOOTKUBE_VERSION=v0.9.1

docker run -it quay.io/coreos/bootkube:$BOOTKUBE_VERSION /bootkube render \
    --asset-dir /generated-templates/ \
    --experimental-self-hosted-etcd \
    && docker cp $(docker ps --last 1 -q):/generated-templates/ ./

# Remove old directories
rm -rf auth/ bootstrap-manifests/ etcd/ manifests/ tls/

# Move generated files into place
cp -r generated-templates/* .
rm -rf generated-templates/
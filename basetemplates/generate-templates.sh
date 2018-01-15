#!/bin/bash
# Render the latest bootkube templates and replace the old one in this directory.

BASEDIR="$(dirname "$0")"

BOOTKUBE_VERSION=v0.9.1

docker run -it quay.io/coreos/bootkube:$BOOTKUBE_VERSION /bootkube render \
    --asset-dir /generated-templates/ \
    --experimental-self-hosted-etcd \
    && docker cp $(docker ps --last 1 -q):/generated-templates/ $BASEDIR

# Remove old directories
rm -rf $BASEDIR/auth/ $BASEDIR/bootstrap-manifests/ $BASEDIR/etcd/ $BASEDIR/manifests/ $BASEDIR/tls/

# Move generated files into place
cp -r $BASEDIR/generated-templates/* .
rm -rf $BASEDIR/generated-templates/
#!/bin/bash -e

source "$(dirname "$0")"/source_me

ks delete storageclass etcd-backup-gce-pd || true

n=0
while [ $n -eq 0 ]; do
  n="$(ks get nodes | grep master | wc -l)"
  sleep 5
done
if [ $(( $n / 2  * 2)) == $n ]; then
  echo "invalid master count ($n)"
  n=1
fi

echo "scaling etcd cluster"
ks patch EtcdCluster kube-etcd --type merge -p '{ "spec": { "size": '$n' } }'

BACKUP="/opt/bootkube/assets/etcd/backup.json"
if [ -f "$BACKUP" ]; then
  echo "configure etcd cluster backup"
  ks patch EtcdCluster kube-etcd --type merge -p "$(cat "$BACKUP")"
else
  echo "no etcd cluster backup configured"
fi

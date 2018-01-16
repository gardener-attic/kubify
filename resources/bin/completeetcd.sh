#!/bin/bash -e

ETCD=kube-etcd-0000.kube-etcd.kube-system.svc.cluster.local
BOOT=/opt/bootkube/assets
BACKUP="$BOOT/etcd/backup.json"

check()
{
  MSG="$1"
  shift
  while ! "$@" >/dev/null 2>&1; do
    if [ -m "$MSG" ]; then
      echo "waiting for $MSG..."
      MSG=
    fi
    sleep 5
  done
}

source "$(dirname "$0")"/source_me

if [ -f "$BOOT/cluster-info" ]; then
  source "$BOOT/cluster-info"
fi
if [ -z "$DNS_SERVICE_IP" ]; then
  DNS_SERVICE_IP=10.241.0.10
fi


check "etcd dns resolution" dig +short @$DNS_SERVICE_IP kube-etcd-0000.kube-etcd.kube-system.svc.cluster.local
IP="$(dig +short @$DNS_SERVICE_IP kube-etcd-0000.kube-etcd.kube-system.svc.cluster.local)"
echo "IP for etcd 0 is $IP"

check "etcd kube proxy access for $IP" wget  -O - http://$IP:2380
echo "etcd now reachable"

ks delete storageclass etcd-backup-gce-pd 2>/dev/null|| true

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

if [ -f "$BACKUP" ]; then
  echo "configure etcd cluster backup"
  ks patch EtcdCluster kube-etcd --type merge -p "$(cat "$BACKUP")"
else
  echo "no etcd cluster backup configured"
fi

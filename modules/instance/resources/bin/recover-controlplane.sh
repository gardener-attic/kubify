#!/bin/bash -e

source "$(dirname "$0")"/source_me

lookup() {
    # Doesn't work with out of the box jq on CoreOS
    #kubectl -n kube-system get pod -o json | jq -r '.items[] | select(.metadata.name|test("'$1'-.*"))|select(.status.phase=="Running")|"\(.metadata.name) \(.status.phase)"'
    ext=
    if [ "$1" == -d ]; then
        shift
        ext="-[a-z0-9]{9,10}"
    fi
    kubectl -n kube-system get pods | (egrep "$1$ext-[a-z0-9]{5} " || true) | (grep Running || true)
}

checkpod() {
    name="$1"
    if [ $# -gt 1 ]; then
        name="$2"
    fi
    pods="$(lookup "$@")"
    if [ -n "$pods" ]; then
        echo "found $name"
        echo "$pods"
    else
        missing=x
        echo "no $name found"
    fi
}

check () {
    missing=
    checkpod kube-apiserver
    checkpod -d kube-controller-manager
    checkpod -d kube-scheduler
}

deploy() {
    echo "deploying temporary control plane"
    sudo mkdir -p /etc/kubernetes/bootstrap-secrets
    sudo cp -r /opt/bootkube/assets/tls/* /etc/kubernetes/bootstrap-secrets/
    sudo cp /opt/bootkube/assets/bootstrap-manifests/bootstrap-apiserver.yaml /etc/kubernetes/manifests/
    sudo cp /opt/bootkube/assets/bootstrap-manifests/bootstrap-controller-manager.yaml /etc/kubernetes/manifests/
    sudo cp /opt/bootkube/assets/bootstrap-manifests/bootstrap-scheduler.yaml /etc/kubernetes/manifests/
}

delete() {
    echo "deleting temporary controlplane"
    sudo rm /etc/kubernetes/manifests/bootstrap-apiserver.yaml
    sudo rm /etc/kubernetes/manifests/bootstrap-controller-manager.yaml
    sudo rm /etc/kubernetes/manifests/bootstrap-scheduler.yaml
}

check

if [ -n "$missing" ]; then
    deploy
    echo "waiting for controlplane"
    while [ -n "$missing" ]; do
        sleep 10
        check
        if [ -z $missing ]; then
            sleep 10
            check
        fi
    done
    delete
fi




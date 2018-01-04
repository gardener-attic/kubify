#!/bin/bash -e

source "$(dirname "$0")"/source_me
watch kubectl get pods --all-namespaces -o wide

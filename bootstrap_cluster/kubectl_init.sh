#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <IP-ADDRESS>"
  exit 1
fi
IP_ADDRESS="$1"

export TALOSCONFIG="$(pwd)/talosconfig"

echo "### Step 1: Fetching kubeconfig..."
talosctl kubeconfig --force --nodes $IP_ADDRESS --endpoints $IP_ADDRESS

echo "### Step 2: Waiting for Node to join the cluster..."
until kubectl get nodes | grep -q "Ready"; do
  echo "Node is not ready yet. Waiting 5s..."
  sleep 5
done

echo "### Success! Node is Ready:"
kubectl get nodes
#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <IP-ADDRESS>"
  exit 1
fi

IP_ADDRESS="$1"
CLUSTER_NAME="${CLUSTER_NAME:-proxmox-talos}"

export TALOSCONFIG="$(pwd)/talosconfig"
# -----------------

echo "------------------------------------"
echo "Cluster Name: $CLUSTER_NAME"
echo "IP Address:   $IP_ADDRESS"
echo "Config File:  $TALOSCONFIG"
echo "------------------------------------"

echo "Step 1: Generate configuration..."
talosctl gen config $CLUSTER_NAME https://$IP_ADDRESS:6443 \
  --config-patch-control-plane 'cluster: { allowSchedulingOnControlPlanes: true }' \
  --force

echo "Step 2: Apply configuration..."
talosctl apply-config --insecure --nodes $IP_ADDRESS --file controlplane.yaml

echo "Step 3: Configure local client..."
talosctl config endpoint $IP_ADDRESS
talosctl config node $IP_ADDRESS

echo "Step 4: Waiting for Node to be ready for Bootstrap (max 60s)..."
sleep 10

echo "Step 5: Bootstrapping..."
n=0
until [ "$n" -ge 20 ]
do
   talosctl bootstrap --nodes $IP_ADDRESS && break
   n=$((n+1))
   echo "Node not ready yet... retry $n/20 in 5s..."
   sleep 5
done

echo "------------------------------------"
echo "DONE! Check status with:"
echo "talosctl health --nodes $IP_ADDRESS"
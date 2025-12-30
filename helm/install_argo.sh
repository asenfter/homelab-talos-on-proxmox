#!/bin/bash

# Exit immediately if any command fails (safety first)
set -e

CONFIG_FILE="argocd-light.yaml"

# 1. Check if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: The file '$CONFIG_FILE' was not found!"
    echo "Please create it first (check previous steps)."
    exit 1
fi

echo "### Step 1: Preparing Helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

echo "### Step 2: Installing / Updating ArgoCD..."
# The trick: 'upgrade --install' makes the script idempotent.
# It installs ArgoCD if it's missing, or updates it if it already exists.
# --create-namespace creates the namespace automatically.
# --wait ensures we pause until all pods are actually running.
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  -f "$CONFIG_FILE" \
  --wait \
  --timeout 5m

# 3. Bootstrap the ArgoCD Application to manage the rest of the apps
echo "### Step 3: Bootstrapping ArgoCD Application to manage the rest of the apps..."
kubectl apply -f bootstrap-app.yaml

echo "### Step 4: Connecting with git repo..."
kubectl -n argocd create secret generic manifests-repo \
  --from-literal=url="$ARGOCD_GIT_REPO_URL" \
  --from-literal=name="$ARGOCD_GIT_REPO_NAME" \
  --from-literal=username="$ARGOCD_GIT_REPO_USERNAME" \
  --from-literal=password="$ARGOCD_GIT_REPO_TOKEN" \
  --dry-run=client -o yaml \
| kubectl label --local -f - \
    argocd.argoproj.io/secret-type=repository \
    --overwrite -o yaml \
| kubectl apply -f -

echo "### Step 5: Retrieving admin password..."
# We fetch the password directly from the cluster secret
ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "------------------------------------------------"
echo "ArgoCD successfully installed!"
echo ""
echo "URL (Tunnel required): https://localhost:8080"
echo "User:                  admin"
echo "Password:              $ADMIN_PASSWORD"
echo "------------------------------------------------"
echo ""
echo "To log in, keep this terminal open (or open a new one) and run:"
echo "kubectl port-forward service/argocd-server -n argocd 8080:443"
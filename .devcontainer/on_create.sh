#! /bin/bash

source .devcontainer/.env

git config --global user.name "$MY_GIT_NAME"
git config --global user.email "$MY_GIT_EMAIL"
git config --global core.ignorecase false


# ----------------------------------------------------------------
# Install talosctl
echo "======== Installing talosctl... ========"
chmod +x .devcontainer/install_taloscli.sh
.devcontainer/install_taloscli.sh
talosctl version
# ----------------------------------------------------------------
# Install kubectl
echo "======== Installing kubectl... ========"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
kubectl version --client --output=yaml
rm -f kubectl kubectl.sha256
# ----------------------------------------------------------------
# Install helm
echo "======== Installing helm... ========"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
# ----------------------------------------------------------------
# Install kubeseal
echo "======== Installing kubeseal... ========"
KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/tags | jq -r '.[0].name' | cut -c 2-)
if [ -z "$KUBESEAL_VERSION" ]; then
    echo "Failed to fetch the latest KUBESEAL_VERSION"
    exit 1
fi
curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
tar -xvzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
rm -f kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal
# ----------------------------------------------------------------
# Install OpenTofu CLI
echo "======== Installing opentofu... ========"
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb
rm -f install-opentofu.sh

#! /bin/bash

source .devcontainer/.env

git config --global user.name "$MY_GIT_NAME"
git config --global user.email "$MY_GIT_EMAIL"
git config --global core.ignorecase false


# ----------------------------------------------------------------
# Install talosctl
curl -sL https://talos.dev/install | sh
# ----------------------------------------------------------------
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
kubectl version --client --output=yaml
# Clean up
rm -f kubectl kubectl.sha256
# ----------------------------------------------------------------
# Install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
# ----------------------------------------------------------------
# Install OpenTofu CLI

# Download the installer script:
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
# Alternatively: wget --secure-protocol=TLSv1_2 --https-only https://get.opentofu.org/install-opentofu.sh -O install-opentofu.sh

# Give it execution permissions:
chmod +x install-opentofu.sh

# Please inspect the downloaded script

# Run the installer:
./install-opentofu.sh --install-method deb

# Remove the installer:
rm -f install-opentofu.sh
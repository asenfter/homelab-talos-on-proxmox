## Talos on Proxmox

This repository automates provisioning and bootstrapping a Talos Linux Kubernetes cluster on Proxmox. OpenTofu creates and configures the virtual machines, Talos bootstrap scripts initialize control plane and worker nodes, and an Helm script installs Argo CD for GitOps workflows.

### Repository Layout
- [terraform/](terraform/) - OpenTofu configuration that creates Talos VMs on Proxmox.
- [bootstrap_cluster/](bootstrap_cluster/) - Talos bootstrap helper scripts for generating kubeconfig and applying node configurations.
- [helm/](helm/) - Lightweight Helm values and installer for deploying Argo CD onto the Talos cluster.


### Environment Variables
All automation scripts expect a `.env` file at the repository root. The template at [.env.tpl](.env.tpl) lists all required variables. **You must keep the Talos version in `TF_VAR_install_iso` in sync with `TALOSCLI_VERSION` in `.devcontainer/devcontainer.json`!**

#### Required variables in `.env`:
```
# Proxmox API target
TF_VAR_pm_api_url="https://<proxmox-host>/api2/json"
# API token credentials (user@realm!token-name)
TF_VAR_pm_api_token_id="<token-id>"
TF_VAR_pm_api_token_secret="<token-secret>"
# Talos installer ISO already present on Proxmox storage (must match TALOSCLI_VERSION)
TF_VAR_install_iso="<storage>:iso/talos-amd64-<talos-version>.iso"
# Optional static MAC address for Talos VMs
TF_VAR_vm_macaddr="<mac-address>"
# Human-friendly cluster identifier used by bootstrap scripts
CLUSTER_NAME="<cluster-name>"
# ArgoCD GitOps repository settings
ARGOCD_GIT_REPO_URL="<repo-url>"
ARGOCD_GIT_REPO_NAME="<repo-name>"
ARGOCD_GIT_REPO_USERNAME="<username>"
ARGOCD_GIT_REPO_TOKEN="<token>"
```

#### Example Talos version sync:
* In `.devcontainer/devcontainer.json`:  
    `"TALOSCLI_VERSION": "1.12.0"`
* In `.env`:  
    `TF_VAR_install_iso="local:iso/talos-amd64-1.12.0.iso"`

If you change the Talos version, update both locations!

#### Additional devcontainer variables (in `.devcontainer/.env`):
```
MY_GIT_NAME="<your name>"
MY_GIT_EMAIL="<your email>"
```


### Talos CLI Installation
The devcontainer automatically installs `talosctl` using the version specified in `TALOSCLI_VERSION`. If you need to install manually:

```
chmod +x .devcontainer/install_taloscli.sh
.devcontainer/install_taloscli.sh
```
This will install the version set in the `TALOSCLI_VERSION` environment variable defined in `.devcontainer/devcontainer.json`.

### Helper Scripts and Tasks
- [bootstrap_cluster/talos_init.sh](bootstrap_cluster/talos_init.sh) - Generates Talos machine configurations, applies them to the control plane, and waits for the cluster to settle.
- [bootstrap_cluster/kubectl_init.sh](bootstrap_cluster/kubectl_init.sh) - Retrieves the Talos kubeconfig, rewrites endpoints, and verifies API access.
- [helm/install_argo.sh](helm/install_argo.sh) - Installs Argo CD using the values in [helm/argocd-light.yaml](helm/argocd-light.yaml).

VS Code tasks are preconfigured to wrap the scripts:
1. run_tofu - Executes tofu inside [terraform/](terraform/), sourcing `.env` first.
2. talos_init - Runs [bootstrap_cluster/talos_init.sh](bootstrap_cluster/talos_init.sh) with the control-plane IP.
3. kubectl_init - Runs [bootstrap_cluster/kubectl_init.sh](bootstrap_cluster/kubectl_init.sh) with the same IP.
4. install_argo - Applies the Argo CD Helm chart using [helm/install_argo.sh](helm/install_argo.sh).

### Development Container
- [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) defines the Debian base image and wires in bootstrap scripts for consistent tooling.
- [.devcontainer/on_create.sh](.devcontainer/on_create.sh) configures Git, installs talosctl, kubectl, helm, and OpenTofu.

### Typical Workflow
1. Download the Talos bare-metal image from https://factory.talos.dev/ and upload it to your Proxmox ISO storage that matches TF_VAR_install_iso.
2. In Proxmox, create the dedicated automation user (for example iac@pve), issue an API token, and grant it privileges (e.g. Administrator).
3. Create `.env` with the environment variables described above.
4. From VS Code, run the run_tofu task with
    - init, 
    - plan
    - and apply
5. Extract the control-plane IP from proxmox vm by starting the dedicated proxmox console
6. Execute the talos_init task, supplying the control-plane IP, to push Talos machine configs to the control plane and workers.
7. Execute the kubectl_init task against the same IP to retrieve and validate Kubernetes credentials.
8. Run install_argo to deploy Argo CD using the Helm values in this repository.

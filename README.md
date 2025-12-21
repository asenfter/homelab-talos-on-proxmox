## Talos on Proxmox

This repository automates provisioning and bootstrapping a Talos Linux Kubernetes cluster on Proxmox. OpenTofu creates and configures the virtual machines, Talos bootstrap scripts initialize control plane and worker nodes, and an optional Helm script installs Argo CD for GitOps workflows.

### Repository Layout
- [terraform/](terraform/) - OpenTofu configuration that creates Talos VMs on Proxmox.
- [bootstrap_cluster/](bootstrap_cluster/) - Talos bootstrap helper scripts for generating kubeconfig and applying node configurations.
- [helm/](helm/) - Lightweight Helm values and installer for deploying Argo CD onto the Talos cluster.

### Environment Variables
All automation scripts expect [.env](.env) at the repository root. The template at [.env.tpl](.env.tpl) mirrors the required keys and can be copied to bootstrap your local secrets.

```
# Proxmox API target
TF_VAR_pm_api_url="https://<proxmox-host>/api2/json"

# API token credentials (user@realm!token-name)
TF_VAR_pm_api_token_id="<token-id>"
TF_VAR_pm_api_token_secret="<token-secret>"

# Talos installer ISO already present on Proxmox storage
TF_VAR_install_iso="<storage>:iso/<talos-image>.iso"

# Human-friendly cluster identifier used by bootstrap scripts
CLUSTER_NAME="<cluster-name>"
```

### Helper Scripts and Tasks
- [bootstrap_cluster/talos_init.sh](bootstrap_cluster/talos_init.sh) - Generates Talos machine configurations, applies them to the control plane, and waits for the cluster to settle.
- [bootstrap_cluster/kubectl_init.sh](bootstrap_cluster/kubectl_init.sh) - Retrieves the Talos kubeconfig, rewrites endpoints, and verifies API access.
- [helm/install_argo.sh](helm/install_argo.sh) - Installs Argo CD using the values in [helm/argocd-light.yaml](helm/argocd-light.yaml).

VS Code tasks are preconfigured in [.vscode/tasks.json](.vscode/tasks.json) to wrap the scripts:
1. run_tofu - Executes tofu inside [terraform/](terraform/), sourcing [.env](.env) first.
2. talos_init - Runs [bootstrap_cluster/talos_init.sh](bootstrap_cluster/talos_init.sh) with the control-plane IP.
3. kubectl_init - Runs [bootstrap_cluster/kubectl_init.sh](bootstrap_cluster/kubectl_init.sh) with the same IP.
4. install_argo - Applies the Argo CD Helm chart using [helm/install_argo.sh](helm/install_argo.sh).

### Development Container
- [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) defines the Debian base image and wires in bootstrap scripts for consistent tooling.
- [.devcontainer/initialize.sh](.devcontainer/initialize.sh) runs on the host before the container starts; it reads [.devcontainer/.env](.devcontainer/.env) to load MY_LOCAL_GIT_SSH_KEY and adds the key to your agent so Git operations succeed inside the container.
- [.devcontainer/on_create.sh](.devcontainer/on_create.sh) configures Git, installs talosctl, kubectl, helm, and OpenTofu.

### Typical Workflow
1. Download the Talos bare-metal image from https://factory.talos.dev/ and upload it to your Proxmox ISO storage that matches TF_VAR_install_iso.
2. In Proxmox, create the dedicated automation user (for example iac@pve), issue an API token, and grant it privileges (e.g. Administrator).
3. Create [.env](.env) with the environment variables described above.
4. From VS Code, run the run_tofu task with
    - init, 
    - plan
    - and apply
5. Extract the control-plane IP from proxmox vm by starting the dedicated proxmox console
6. Execute the talos_init task, supplying the control-plane IP, to push Talos machine configs to the control plane and workers.
7. Execute the kubectl_init task against the same IP to retrieve and validate Kubernetes credentials.
8. Run install_argo to deploy Argo CD using the Helm values in this repository.


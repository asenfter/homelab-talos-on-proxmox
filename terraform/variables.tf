variable "pm_api_url" {
    description = "This is the target Proxmox API endpoint"
    type = string
}
variable "pm_api_token_id" {
    description = "This is the Proxmox API user. Use root@pam or custom. Will need PVEDatastoreUser, PVEVMAdmin, PVETemplateUser permissions"
    type = string
    sensitive = true
}
variable "pm_api_token_secret" {
    description = "API user password. Required, sensitive, or use environment variable TF_VAR_proxmox_api_pass"
    sensitive = true
    type = string
}
variable "pm_tls_insecure" {
    description = "Disable TLS verification while connecting"
    type = bool
    default = true
}

variable "target_node" {
    description = "Default Proxmox node to host Talos VMs"
    type = string
    default = "host1"
}

variable "install_iso" {
    description = "Storage path to the Talos installer ISO (e.g. local:iso/talos.iso)"
    type = string
}

variable "storage_pool" {
    description = "Datastore name used for VM disks"
    type = string
    default = "local-lvm"
}

variable "vm_bridge" {
    description = "Proxmox network bridge for Talos VMs"
    type = string
    default = "vmbr0"
}

variable "vm_macaddr" {
    description = "Optional static MAC address for Talos VMs"
    type = string
}

variable "enable_agent" {
    description = "Set true when the guest has the QEMU agent installed"
    type = bool
    default = false
}

variable "nodes" {
    description = "Talos node definitions keyed by VM name"
    type = map(object({
        role    = string
        memory  = number
        cores   = number
        disk_size = string
    }))

    default = {
        "k8s-cp-0" = {
            role    = "controlplane"
            memory  = 10240
            cores   = 8
            disk_size = "100G"
        }
    }
}
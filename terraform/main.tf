resource "proxmox_vm_qemu" "talos" {
  for_each    = var.nodes
  name        = each.key
  target_node = var.target_node

  # Boot from ISO to perform a fresh Talos install
  iso       = var.install_iso
  boot      = "order=ide2;scsi0;net0"
  bootdisk  = "scsi0"

  cores  = each.value.cores
  memory = each.value.memory

  # Recommended Proxmox guest settings
  scsihw = "virtio-scsi-pci"
  agent  = var.enable_agent ? 1 : 0

  # Network
  network {
    model  = "virtio"
    bridge = var.vm_bridge
  }

  # Primary system disk
  disk {
    type    = "scsi"
    storage = var.storage_pool
    size    = each.value.disk_size
  }

  # Optional: keep it predictable for Talos
  onboot = true
}

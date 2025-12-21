output "talos_vm_names" {
  value = keys(proxmox_vm_qemu.talos)
}

# Depending on your Proxmox/provider version, IPs may not always populate reliably.
# This is still useful when QEMU agent + DHCP cooperate.
output "talos_vm_ips" {
  value = [for vm in values(proxmox_vm_qemu.talos) : try(vm.default_ipv4_address, null)]
}

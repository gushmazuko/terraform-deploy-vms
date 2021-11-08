output "ip_address" {
  value       = proxmox_vm_qemu.proxmox_vm[*].ssh_host
  description = "VM IP Address"
}

output "vm_id" {
  value       = proxmox_vm_qemu.proxmox_vm[*].id
  description = "VM ID"
}
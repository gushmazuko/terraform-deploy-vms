variable "vm_count" {
  type = number
  default = "1"
  description = "count VM machines"
}
variable "pm_ip" {
  type = string
  description = "Proxmox IP"
}
variable "pm_user" {
  type = string
  description = "Proxmox username in format: root@pam"
}
variable "pm_password" {
  type = string
  description = "Proxmox password"
}
variable "pm_port" {
  type = number
  description = "Proxmox SSH port"
}
variable "pm_private_key" {
  description = "Full path to your private SSH key"
  type = string
  default = ""
}
variable "pm_otp" {
  type = string
  default = ""
  description = "Proxmox OTP"
}
variable "target_node" {
  type = string
  description = "Target Proxmox node name"
}
variable "vm_name" {
  type = string
  description = "Name of VM"
}
variable "vm_desc" {
  type = string
  default = "Dployed with Terraform"
}
variable "vm_template" {
  type = string
  description = "Clone from template"
}
variable "vm_cores" {
  type = number
  default = 4
  description = "VM cores"
}
variable "vm_socket" {
  type = number
  default = 1
  description = "VM cores"
}
variable "vm_cpu" {
  type = string
  default = "host"
  description = "VM CPU"
}
variable "vm_memory" {
  type = number
  default = 2048
  description = "VM Memory"
}
variable "vm_storage" {
  type = string
  default = "local-zfs"
  description = "VM emplacement storage"
}
variable "vm_system_disk_size" {
  type = string
  default = "32G"
  description = "System Disk Size in GB"
}
variable "vm_balloon" {
  type = number
  default = 0
  description = "VM balloon"
}
variable "vm_numa" {
  type = bool
  default = true
  description = "VM NUMA"
}
variable "vm_bridge" {
  type = string
  default = "vmbr0"
  description = "vm bridge"
}
variable "vm_tag" {
  type = number
  default = -1
  description = "The VLAN tag to apply to packets on this device. -1 disables VLAN tagging"
}
variable "vm_timezone" {
  type = string
  default = "Europe/Berlin"
}
variable "vm_locales" {
  type = string
  default = "en_US.UTF-8"
}
variable "vm_data_disk_size" {
  description = "Size of VM disk in GB"
  type = string
  default = "32G"
}
variable "vm_subnet" {
  description = "Assign IP to VM. Set 'IP address' or 'dhcp' to recover IP over DHCP"
  type = string
  default = "dhcp"
}
variable "vm_hostnum" {
  description = "First host number to assign in the subnet"
  type = number
  default = "1"
}
variable "vm_prefix" {
  description = "Network Netmask in CIDR"
  type = number
  default = 24
}
variable "vm_gateway" {
  description = "VM's Gateway for static IP"
  type = string
  default = ""
}
variable "vm_dns1" {
  description = "VM's 1st DNS for static IP"
  type = string
  default = ""
}
variable "vm_dns2" {
  description = "VM's 2nd DNS for static IP"
  type = string
  default = ""
}
variable "vm_searchdomain" {
  description = "DNS search domain"
  type = string
  default = ""
}
variable "vm_domain" {
  description = "VM's domain name"
  type = string
  default = ""
}
variable "vm_ssh_authorized_key_1" {
  description = "1st authorized SSH public key string or leave blank"
  type = string
}
variable "vm_ssh_authorized_key_2" {
  description = "2nd authorized SSH public key string or leave blank"
  type = string
  default = ""
}
variable "vm_ssh_port" {
  description = "Custom SSH Port to set inside VM"
  type = number
  default = 22
}
variable "vm_ciuser" {
  description = "Cloud-Init default user's login"
  type = string
}
variable "vm_cipass" {
  description = "Cloud-Init default user's SHA-512 hashed password"
  type = string
}
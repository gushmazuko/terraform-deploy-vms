terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = ">2.0.0"
    }
  }
    required_version = ">= 0.13"
}
provider "proxmox" {
  pm_parallel       = 4
  pm_tls_insecure   = true
  pm_api_url        = "https://${var.pm_ip}:8006/api2/json"
  pm_user           = var.pm_user
  pm_password       = var.pm_password
  pm_otp            = ""
}

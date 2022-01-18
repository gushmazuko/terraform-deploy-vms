/* Create a local copy of the file, to transfer to Proxmox */
resource "local_file" "cloud_init_user_data_file" {
  count    = var.vm_count
  content   = data.template_file.user_data[count.index].rendered
  # filename  = "${path.module}/.terraform/user_data_vm-${count.index}.yaml"
  filename  = (var.vm_count > 1 ? "${path.module}/.terraform/user_data_${var.vm_name}-0${count.index + 1}.yaml" : "${path.module}/.terraform/user_data_${var.vm_name}.yaml")
}

/* Null resource that generates a cloud-config file per VM & Transfer the file to the Proxmox Host */
resource "null_resource" "push_cloud_init" {
  count    = var.vm_count
  connection {
    type        = "ssh"
    user        = "root"
    host        = var.pm_ip
    port        = var.pm_port
    /* If your private key is protected by a password comment `private_key` argument and use `agent` instead. Then import your key with: `ssh-add ~/.ssh/id_ed25519_privkey` */
    # private_key = file("${var.pm_private_key}")
    agent       = true
  }

  provisioner "file" {
    source       = local_file.cloud_init_user_data_file[count.index].filename
    # destination  = "/var/lib/vz/snippets/user_data_vm-${count.index}.yaml"
    destination          = (var.vm_count > 1 ? "/var/lib/vz/snippets/user_data_${var.vm_name}-0${count.index + 1}.yaml" : "/var/lib/vz/snippets/user_data_${var.vm_name}.yaml")
  }
}

/* Create the VM */
resource "proxmox_vm_qemu" "proxmox_vm" {
  depends_on = [
    null_resource.push_cloud_init
  ]
  count                   = var.vm_count
  /* Increment name if 'count' is more than '1' */
  name                    = (var.vm_count > 1 ? "${var.vm_name}-0${count.index + 1}" : var.vm_name)
  # name                    = var.vm_name
  target_node             = var.target_node
  clone                   = var.vm_template
  full_clone              = true
  os_type                 = "cloud-init"
  cores                   = var.vm_cores
  sockets                 = var.vm_socket
  cpu                     = var.vm_cpu
  memory                  = var.vm_memory
  scsihw                  = "virtio-scsi-single"
  bootdisk                = "virtio0"
  /* Boot order: (c:CDROM -> d:Disk -> n:Network); Cloud-Init use CDROM */
  boot                    = "c"
  balloon                 = var.vm_balloon
  numa                    = var.vm_numa
  hotplug                 = "network,disk,usb,memory,cpu"
  onboot                  = true
  agent                   = 1
  define_connection_info  = true
  #vmid                    = 0
  desc                    = var.vm_desc
  # cicustom                = "user=local:snippets/user_data_vm-${count.index}.yaml"
  cicustom                = (var.vm_count > 1 ? "user=local:snippets/user_data_${var.vm_name}-0${count.index + 1}.yaml" : "user=local:snippets/user_data_${var.vm_name}.yaml")
  /* If 'var.vm_subnet' value not equals to 'dhcp' set static IP configuration. FYI: https://www.terraform.io/docs/language/functions/cidrhost.html */
  ipconfig0               = (var.vm_subnet != "dhcp" ? "ip=${cidrhost("${var.vm_subnet}/${var.vm_prefix}", "${count.index + "${var.vm_hostnum}"}")}/${var.vm_prefix},gw=${var.vm_gateway}": "ip=dhcp")
  # ipconfig0               = "ip=dhcp"
  nameserver              = (var.vm_subnet != "dhcp" ? "${var.vm_dns1}" : "")
  searchdomain            = (var.vm_subnet != "dhcp" ? "${var.vm_searchdomain}" : "")

  disk {
    size      = var.vm_system_disk_size
    type      = "virtio"
    storage   = var.vm_storage
    format    = "raw"
    discard   = "on"
    cache     = "writeback"
    iothread  = 1
    }
  /* Add second storage drive to VM */
  # disk {
  #   size      = var.vm_data_disk_size
  #   type      = "virtio"
  #   storage   = var.vm_storage
  #   format    = "raw"
  #   discard   = "on"
  #   cache     = "writeback"
  #   iothread  = 1
  #   }
  network {
    model     = "virtio"
    bridge    = var.vm_bridge
    # macaddr = "00:AA:41:62:60:31"
    # firewall  = false
    tag       = var.vm_tag
  }
  /* Serial interface of type socket is used by xterm.js */
  serial {
    id    = 0
    type  = "socket"
  }
  lifecycle {
    ignore_changes  = [
      network
    ]
  }
  timeouts {
    create = "10m"
  }
}
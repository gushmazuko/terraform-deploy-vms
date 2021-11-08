data "template_file" "user_data" {
  count    = var.vm_count
  template          = file("./cloud-init/user_data.yaml")
  vars              = {
    locale          = var.vm_locales
    timezone        = var.vm_timezone
    hostname        = (var.vm_count > 1 ? "${var.vm_name}-0${count.index + 1}" : var.vm_name)
    domain          = var.vm_domain
    ciuser          = var.vm_ciuser
    cipass          = var.vm_cipass
    ssh_authorized_key_1  = var.vm_ssh_authorized_key_1
    ssh_authorized_key_2  = var.vm_ssh_authorized_key_2
    ssh_port        = var.vm_ssh_port
  }
}
# Deploy a VM to Proxmox with Terraform

Deploy your Infrastructure as Code via Terraform & Cloud-Init

## Requirements
- Cloud Init enabled VM Template on Proxmox


## Create Cloud-Init VM Template
Refer to [Ansible-Playbooks](https://github.com/gushmazuko/ansible-playbooks)


## Create `user` and `password` for Terraform
Connect to Proxmox via SSH and create `terraform@pve` user with necessary rights:
- Add `TerraformDeploy` with assigned rights:
```bash
pveum role add TerraformDeploy -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit"
```
- Generate a random password
```bash
pw_terraform="$(pwgen -1 -n 32)"
echo "the password for terraform usrer is: $pw_terraform"
```
- Create `terraform` PVE user
```bash
pveum user add terraform@pve --password "${pw_terraform}" --comment "For deployment only"
```
- Assign `TerraformDeploy` role to user
```bash
pveum aclmod / --user terraform@pve --role TerraformDeploy
```


## SSH Connection to Proxmox VE
Terraform need to copy cloud-init config file to Proxmox via SSH. 

Define full path of your SSH private key  to `pm_private_key` variable. If your private key is protected by a password comment `private_key` argument and use `agent` instead.  
Edit `infra.tf`:

```bash
resource "null_resource" "push_cloud_init" {
  count    = var.vm_count
  connection {
    ...
    #private_key = file("${var.pm_private_key}")
    agent       = true
  }
  ```
 
 Then import your key in interactive mode in terminal:
 ```bash
 ssh-add ~/.ssh/id_ed25519_privkey
 ```

## Cloud-Init
Generate Cloud-Init user password
```bash
mkpasswd --method=SHA-512 --rounds=4096
```

Assign it to variable `vm_cipass` in `terraform.tfvars`


## Variable Values
### Declaring Variable
All variables, they descriptions and some default values are declared in `variables.tf`. There is no place to define variables, it just declare that the variable exists!

### Variable Definitions
Copy `terraform.tfvars.example` to `terraform.tfvars` and define your values. If you leave empty any variable Terraform will prompt you in interactive mode.

### Override variables on the Command Line
Argument `-var` has a higher priority than `var-file` and will override pre-defined variable 
```bash
terraform apply -var-file=terraform.tfvars \
-var="vm_name=debian-11-test" \
-var="vm_template=ci-debian-11-tpl"
```


## VM Network Settings
### DHCP
By default variable `vm_subnet` is set to value `dhcp` and Virtual Machine will be created with enabled DHCP.  
### Static IP
For static IP set following variables:

- `vm_subnet = "172.16.0.0"` - Subnet address (**Requird**)
- `vm_prefix = "24"` - Subnet prefix in CIDR (**Requird**)
- `vm_hostnum = "10"` - Host number in subnet (**Requird**)
- `vm_gateway = "172.16.0.254"` - Network gateway
- `vm_dns1 = "172.16.0.254"` - 1st DNS Nameserver
- `vm_searchdomain = "network.lan"` - DNS Search domain

In the example above the first VM will have IP address: `172.16.0.10/24`  

### Multiple VM with static IP
By setting IP of first VM, `cidrhost` function will increment IP of other VMs
```bash
terraform plan -var-file=terraform.tfvars \
-var="vm_name=docker-worker" \
-var="vm_template=ci-debian-11-tpl" \
-var="vm_count=3" \
-var="vm_subnet=172.16.0.0" \
-var="vm_prefix=24" \
-var="vm_hostnum=100" \
-var="vm_gateway=172.16.0.254"
```

Terraform will create 3 VMs with static IP:
- `docker-worker-01: 172.16.0.100/24`
- `docker-worker-02: 172.16.0.101/24`
- `docker-worker-03: 172.16.0.102/24`


For more information, visit:
- [cidrhost Function](https://www.terraform.io/docs/language/functions/cidrhost.html)
- [IP Calculator](http://jodies.de/ipcalc?host=172.16.0.0&mask1=24&mask2=)


## Deployment
- Initialize a working directory
```bash
terraform init
```

- Validate config
```bash
terraform validate
```

- See working plan
```bash
terraform plan -var-file=terraform.tfvars
```

- Deploy VM
```bash
terraform apply -var-file=terraform.tfvars 
```

> ⚠️ **Caution**: Terraform will propose the plan to you and prompt you to approve it before taking the described actions, unless you waive that prompt by using the `-auto-approve` option. Use it with **caution**!


## ⚠️ Post Deployment
If you do not plan to change the configuration of machines via Terraform in the future and use it only for one-time deployment, delete the state file immediately after completion. Otherwise, when you create a new machine, you will simply overwrite the previously created one.

- Delete all states:
```bash
terraform state list | cut -f 1 -d '[' | xargs -L 1 terraform state rm
```

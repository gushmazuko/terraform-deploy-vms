# Terraform Deploy Virtual Machines

Deploy your Infrastructure as Code via Terraform & Cloud-Init

Find `README.md` in *each* provider subfolder:
```bash
.
├── LICENSE
├── proxmox
│   ├── cloud-init
│   │   └── user_data.yaml
│   ├── data.tf
│   ├── infra.tf
│   ├── output.tf
│   ├── provider.tf
│   ├── README.md
│   ├── terraform.tfvars.example
│   └── variables.tf
└── README.md
```

List of Providers:
- [Proxmox VE](./proxmox/)

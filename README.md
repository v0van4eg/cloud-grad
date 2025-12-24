# Dream Platform Infrastructure

This Terraform project creates the infrastructure for the Dream Platform on Yandex Cloud, including networking, compute resources, database, and container registry.

## Project Structure

```
/workspace/
├── main.tf              # Main infrastructure resources
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── terraform.tfvars     # Default variable values
├── provider.tf          # Provider configuration
├── versions.tf          # Terraform and provider versions
├── README.md            # This file
├── cloud_id.txt         # Cloud credentials (should be secured)
└── key.json             # Service account key file
```

## Prerequisites

1. **Yandex Cloud CLI**: Install and configure the Yandex Cloud CLI
2. **Terraform**: Install Terraform >= 1.9.7
3. **SSH Key**: Generate an SSH key pair for VM access
4. **Service Account**: Create a service account with appropriate permissions and download the key file as `key.json`

## Configuration

### Required Variables

You need to provide the following variables:

- `cloud_id`: Your Yandex Cloud ID
- `folder_id`: Your Yandex Cloud folder ID
- `ssh_public_key`: Your SSH public key for VM access
- `db_users`: Map of database usernames and passwords

### Example terraform.tfvars file:

```hcl
cloud_id       = "your-cloud-id-here"
folder_id      = "your-folder-id-here"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E... your-public-key-here"

db_users = {
  kirill_morozov = "secure_password_1"
  appuser        = "secure_password_2"
}
```

## Usage

### Initialize the project:
```bash
terraform init
```

### Plan the deployment:
```bash
terraform plan
```

### Apply the configuration:
```bash
terraform apply
```

### Destroy the infrastructure:
```bash
terraform destroy
```

## Security Considerations

1. **Sensitive Data**: Never commit sensitive data like passwords or private keys to version control
2. **SSH Keys**: Store your SSH private key securely and restrict access
3. **Service Account Keys**: Protect the `key.json` file with proper file permissions
4. **Database Passwords**: Use strong, unique passwords for database users
5. **Lockbox**: The project uses Yandex Lockbox to store database passwords securely

## Resources Created

- **VPC Network**: Isolated network for the infrastructure
- **Subnets**: Two subnets in different availability zones
- **Virtual Machines**: Configurable number of compute instances
- **Container Registry**: Private container registry
- **PostgreSQL Cluster**: Managed PostgreSQL database cluster
- **Database Users**: Configurable database users
- **Database**: Application database
- **Lockbox Secrets**: Secure storage for database passwords

## Outputs

After deployment, the following outputs will be available:

- `network_id`: ID of the created VPC network
- `subnet_ids`: IDs of the created subnets
- `vm_external_ips`: External IP addresses of the VMs
- `vm_internal_ips`: Internal IP addresses of the VMs
- `db_cluster_id`: ID of the PostgreSQL cluster
- `db_connection_string`: Connection string for the database
- `container_registry_url`: URL of the container registry
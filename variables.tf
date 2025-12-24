# Cloud and folder configuration
variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "zone" {
  description = "Default availability zone"
  type        = string
  default     = "ru-central1-a"
}

# Network configuration
variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "dream-platform-network"
}

variable "subnet_names" {
  description = "Names of the subnets"
  type        = map(string)
  default = {
    subnet_a = "dream-platform-subnet-a"
    subnet_b = "dream-platform-subnet-b"
  }
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type        = map(string)
  default = {
    subnet_a = "10.1.0.0/24"
    subnet_b = "10.2.0.0/24"
  }
}

# VM configuration
variable "instance_count" {
  description = "Number of VM instances to create"
  type        = number
  default     = 1
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "ubuntu-vm"
}

variable "vm_cores" {
  description = "Number of CPU cores for VMs"
  type        = number
  default     = 2
}

variable "vm_core_fraction" {
  description = "Core fraction for VMs"
  type        = number
  default     = 20
}

variable "vm_memory" {
  description = "Amount of memory for VMs in GB"
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  description = "Boot disk size for VMs in GB"
  type        = number
  default     = 10
}

variable "platform_id" {
  description = "Platform ID for VMs"
  type        = string
  default     = "standard-v3"
}

variable "image_id" {
  description = "Image ID for VMs"
  type        = string
  default     = "fd883qojk2a3hruf8p7m"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

# Container registry configuration
variable "registry_name" {
  description = "Name of the container registry"
  type        = string
  default     = "dream-platform-registry"
}

# Database configuration
variable "db_cluster_name" {
  description = "Name of the PostgreSQL cluster"
  type        = string
  default     = "dream-platform-db"
}

variable "db_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "db_resource_preset" {
  description = "Resource preset for database"
  type        = string
  default     = "s2.micro"
}

variable "db_disk_type" {
  description = "Disk type for database"
  type        = string
  default     = "network-ssd"
}

variable "db_disk_size" {
  description = "Disk size for database in GB"
  type        = number
  default     = 10
}

variable "db_database_name" {
  description = "Name of the database"
  type        = string
  default     = "dream-platform"
}

variable "db_users" {
  description = "Map of database users with their passwords"
  type        = map(string)
  sensitive   = true
}
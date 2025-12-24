# Network outputs
output "network_id" {
  description = "ID of the created VPC network"
  value       = yandex_vpc_network.dream_platform_network.id
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value = {
    subnet_a = yandex_vpc_subnet.dream_platform_subnet_a.id
    subnet_b = yandex_vpc_subnet.dream_platform_subnet_b.id
  }
}

# VM outputs
output "vm_external_ips" {
  description = "External IP addresses of the VMs"
  value       = [for vm in yandex_compute_instance.vm : vm.network_interface[0].nat_ip_address]
  sensitive   = true
}

output "vm_internal_ips" {
  description = "Internal IP addresses of the VMs"
  value       = [for vm in yandex_compute_instance.vm : vm.network_interface[0].ip_address]
}

output "vm_ids" {
  description = "IDs of the created VMs"
  value       = [for vm in yandex_compute_instance.vm : vm.id]
}

# Database outputs
output "db_cluster_id" {
  description = "ID of the PostgreSQL cluster"
  value       = yandex_mdb_postgresql_cluster.dream_platform_db.id
}

output "db_cluster_name" {
  description = "Name of the PostgreSQL cluster"
  value       = yandex_mdb_postgresql_cluster.dream_platform_db.name
}

output "db_connection_string" {
  description = "Connection string for the PostgreSQL cluster"
  value       = "postgresql://${yandex_mdb_postgresql_user.kirill_morozov.name}@${yandex_mdb_postgresql_cluster.dream_platform_db.host[0].fqdn}:6432/${var.db_database_name}"
  sensitive   = true
}

output "db_host_fqdn" {
  description = "FQDN of the PostgreSQL cluster host"
  value       = yandex_mdb_postgresql_cluster.dream_platform_db.host[0].fqdn
}

# Container registry outputs
output "container_registry_id" {
  description = "ID of the container registry"
  value       = yandex_container_registry.dream_platform_registry.id
}

output "container_registry_name" {
  description = "Name of the container registry"
  value       = yandex_container_registry.dream_platform_registry.name
}

output "container_registry_url" {
  description = "URL of the container registry"
  value       = yandex_container_registry.dream_platform_registry.url
}
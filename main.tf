# ========== NETWORKING RESOURCES ==========
# VPC Network
resource "yandex_vpc_network" "dream_platform_network" {
  name        = var.network_name
  description = "VPC network for Dream Platform infrastructure"
}

# Subnets
resource "yandex_vpc_subnet" "dream_platform_subnet_a" {
  name           = var.subnet_names.subnet_a
  zone           = var.zone
  network_id     = yandex_vpc_network.dream_platform_network.id
  v4_cidr_blocks = [var.subnet_cidrs.subnet_a]
  description    = "Subnet A for Dream Platform infrastructure"
}

resource "yandex_vpc_subnet" "dream_platform_subnet_b" {
  name           = var.subnet_names.subnet_b
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.dream_platform_network.id
  v4_cidr_blocks = [var.subnet_cidrs.subnet_b]
  description    = "Subnet B for Dream Platform infrastructure"
}

# ========== COMPUTE RESOURCES ==========
# Virtual Machines
resource "yandex_compute_instance" "vm" {
  count        = var.instance_count
  name         = "${var.vm_name_prefix}-${count.index}"
  platform_id  = var.platform_id
  zone         = yandex_vpc_subnet.dream_platform_subnet_a.zone
  hostname     = "${var.vm_name_prefix}-${count.index}.internal"

  resources {
    cores         = var.vm_cores
    core_fraction = var.vm_core_fraction
    memory        = var.vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.vm_disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.dream_platform_subnet_a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "yc-user:${var.ssh_public_key}"
  }

  allow_stopping_for_update = true

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"]  # Ignore changes to SSH keys after creation to prevent unnecessary updates
    ]
  }
}

# ========== SECRET MANAGEMENT ==========
# Using the db_users variable instead of hardcoded passwords
resource "yandex_lockbox_secret" "db_passwords" {
  for_each = var.db_users
  name     = "db-password-${each.key}"
  description = "Database password for user ${each.key}"
}

resource "yandex_lockbox_secret_version" "db_password_versions" {
  for_each  = var.db_users
  secret_id = yandex_lockbox_secret.db_passwords[each.key].id

  entries {
    key        = "password"
    text_value = each.value
  }
}

# ========== CONTAINER REGISTRY ==========
resource "yandex_container_registry" "dream_platform_registry" {
  name        = var.registry_name
  description = "Container registry for Dream Platform"
}

# ========== DATABASE RESOURCES ==========
# PostgreSQL Cluster
resource "yandex_mdb_postgresql_cluster" "dream_platform_db" {
  name        = var.db_cluster_name
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.dream_platform_network.id

  config {
    version = var.db_version
    resources {
      resource_preset_id = var.db_resource_preset
      disk_type_id       = var.db_disk_type
      disk_size          = var.db_disk_size
    }
  }

  host {
    zone      = yandex_vpc_subnet.dream_platform_subnet_b.zone
    subnet_id = yandex_vpc_subnet.dream_platform_subnet_b.id
  }

  depends_on = [
    yandex_vpc_subnet.dream_platform_subnet_b
  ]
}

# PostgreSQL Users
resource "yandex_mdb_postgresql_user" "db_users" {
  for_each   = var.db_users
  cluster_id = yandex_mdb_postgresql_cluster.dream_platform_db.id
  name       = each.key
  password   = each.value
}

# PostgreSQL Database
resource "yandex_mdb_postgresql_database" "dream_platform_db_database" {
  cluster_id = yandex_mdb_postgresql_cluster.dream_platform_db.id
  name       = var.db_database_name
  owner      = yandex_mdb_postgresql_user.db_users["kirill_morozov"].name
}

# ========== LEGACY SUPPORT ==========
# Keep these outputs for backward compatibility with existing references
locals {
  instance_count = var.instance_count
}
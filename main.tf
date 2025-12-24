# ========== RESOURCES ==========
# 1. СЕТЬ
resource "yandex_vpc_network" "dream_platform_network" {
  name = "dream-platform-network"
}

# 2. ПОДСЕТИ
resource "yandex_vpc_subnet" "dream_platform_subnet_a" {
  name           = "dream-platform-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.dream_platform_network.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

resource "yandex_vpc_subnet" "dream_platform_subnet_b" {
  name           = "dream-platform-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.dream_platform_network.id
  v4_cidr_blocks = ["10.2.0.0/24"]
}

# 3. ВИРТУАЛЬНАЯ МАШИНА
resource "yandex_compute_instance" "vm" {
  count       = local.instance_count
  name        = "ubuntu-vm-${count.index}"
  platform_id = "standard-v3"
  zone        = yandex_vpc_subnet.dream_platform_subnet_a.zone

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd883qojk2a3hruf8p7m"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.dream_platform_subnet_a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ycuser:${file("~/.ssh/id_rsa.pub")}"
  }
}

# 4. LOCKBOX (создаём 2 секрета без фиксированных имён)
resource "yandex_lockbox_secret" "db_password_1" {}

resource "yandex_lockbox_secret_version" "db_password_1_version" {
  secret_id = yandex_lockbox_secret.db_password_1.id
  entries {
    key        = "postgresql_password"
    text_value = "Grifonid1"
  }
}

resource "yandex_lockbox_secret" "db_password_2" {}

resource "yandex_lockbox_secret_version" "db_password_2_version" {
  secret_id = yandex_lockbox_secret.db_password_2.id
  entries {
    key        = "postgresql_password"
    text_value = "Grifonid1"
  }
}


# 5. CONTAINER REGISTRY
resource "yandex_container_registry" "docker_registry" {
  name = "dream-platform-registry"
}



# 8. POSTGRESQL CLUSTER
resource "yandex_mdb_postgresql_cluster" "dream_platform_db" {
  name        = "dream-platform-db"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.dream_platform_network.id

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 10
    }
  }

  host {
    zone      = yandex_vpc_subnet.dream_platform_subnet_b.zone
    subnet_id = yandex_vpc_subnet.dream_platform_subnet_b.id
  }
}

# 9. ПЕРВЫЙ ПОЛЬЗОВАТЕЛЬ БД
resource "yandex_mdb_postgresql_user" "kirill_morozov" {
  cluster_id = yandex_mdb_postgresql_cluster.dream_platform_db.id
  name       = "kirill_morozov"
  password   = "Grifonid1"
}

# 10. НОВЫЙ ПОЛЬЗОВАТЕЛЬ БД
resource "yandex_mdb_postgresql_user" "appuser" {
  cluster_id = yandex_mdb_postgresql_cluster.dream_platform_db.id
  name       = "appuser"
  password   = "Grifonid1"
}

# 11. POSTGRESQL DATABASE
resource "yandex_mdb_postgresql_database" "dream_platform" {
  cluster_id = yandex_mdb_postgresql_cluster.dream_platform_db.id
  name       = "dream-platform"
  owner      = yandex_mdb_postgresql_user.kirill_morozov.name
}

# ========== ЛОКАЛЬНЫЕ ЗНАЧЕНИЯ ==========
locals {
  instance_count = 1
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}

# ========== ПЕРЕМЕННЫЕ ==========
variable "service_account_id" {
  description = "ID сервисного аккаунта для управления бакетами"
  type        = string
  default     = "ajeomb05ohoh6mafogio"
}

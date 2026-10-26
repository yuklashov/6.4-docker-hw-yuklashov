terraform {
  required_version = ">= 1.5, < 2.0"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.130, < 1.0"
    }
  }
}

# Authentication comes from YC_TOKEN; do not write tokens into tfvars.
provider "yandex" {
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

variable "folder_id" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "operator_cidr" {
  description = "Current operator public IPv4 with /32; only SSH is exposed."
  type        = string
  validation {
    condition     = can(cidrhost(var.operator_cidr, 0)) && endswith(var.operator_cidr, "/32")
    error_message = "Provide the operator IPv4 /32."
  }
}

resource "yandex_vpc_network" "lab" {
  name = "netology-gitlab-lab"
}

resource "yandex_vpc_subnet" "lab" {
  name           = "netology-gitlab-lab-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.lab.id
  v4_cidr_blocks = ["10.77.10.0/24"]
}

resource "yandex_vpc_security_group" "lab" {
  name       = "netology-gitlab-lab-ssh"
  network_id = yandex_vpc_network.lab.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.operator_cidr]
    description    = "Operator SSH and local HTTP tunnel"
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "gitlab" {
  name        = "netology-gitlab-lab"
  hostname    = "netology-gitlab-lab"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  labels = {
    purpose    = "netology-gitlab"
    disposable = "true"
  }
  resources {
    cores         = 4
    core_fraction = 100
    memory        = 8
  }
  boot_disk {
    auto_delete = true
    initialize_params {
      name     = "netology-gitlab-lab-boot"
      image_id = "fd8a30ptg5tdapq35dlb"
      type     = "network-ssd"
      size     = 60
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.lab.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.lab.id]
  }
  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
      ssh_public_key = trimspace(var.ssh_public_key)
    })
  }
}

output "public_ip" {
  value = yandex_compute_instance.gitlab.network_interface[0].nat_ip_address
}

output "instance_id" {
  value = yandex_compute_instance.gitlab.id
}

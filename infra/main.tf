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
  zone      = "ru-central1-d"
}

variable "folder_id" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "operator_cidrs" {
  description = "Current operator public IPv4 with /32; only SSH is exposed."
  type        = list(string)
  validation {
    condition     = length(var.operator_cidrs) > 0 && alltrue([for c in var.operator_cidrs : can(cidrhost(c, 0)) && endswith(c, "/32")])
    error_message = "Provide the operator IPv4 /32."
  }
}

variable "subnet_id" {
  description = "Existing subnet to reuse without modifying its configuration."
  type        = string
}

data "yandex_vpc_subnet" "shared" {
  subnet_id = var.subnet_id
}

resource "yandex_vpc_security_group" "lab" {
  name       = "netology-gitlab-lab-ssh"
  network_id = data.yandex_vpc_subnet.shared.network_id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = var.operator_cidrs
    description    = "Operator SSH and local HTTP tunnel"
  }
  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = var.operator_cidrs
    description    = "Alternative SSH transport for operator routes"
  }
  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = var.operator_cidrs
    description    = "Operator reachability diagnostics"
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
  zone        = "ru-central1-d"
  labels = {
    purpose    = "netology-gitlab"
    disposable = "true"
  }
  resources {
    cores         = 2
    core_fraction = 100
    memory        = 8
  }
  boot_disk {
    auto_delete = true
    initialize_params {
      name     = "netology-gitlab-lab-boot"
      image_id = "fd8a30ptg5tdapq35dlb"
      type     = "network-hdd"
      size     = 20
    }
  }
  network_interface {
    subnet_id          = data.yandex_vpc_subnet.shared.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.lab.id]
  }
  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
      ssh_public_key   = trimspace(var.ssh_public_key)
      bootstrap_script = file("${path.module}/bootstrap-gitlab.sh")
    })
  }
}

output "public_ip" {
  value = yandex_compute_instance.gitlab.network_interface[0].nat_ip_address
}

output "instance_id" {
  value = yandex_compute_instance.gitlab.id
}

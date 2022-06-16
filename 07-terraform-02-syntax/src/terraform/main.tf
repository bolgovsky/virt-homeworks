terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  #  token     = "<OAuth>"
  service_account_key_file = "key.json"
  cloud_id                 = "b1g2d742rcmsdqcj615o"
  folder_id                = "b1g3jugliqbmg2eomqbj"
  zone                     = "ru-central1-a"
}


// Create a new instance
resource "yandex_compute_instance" "vm-01" {
  name = "netology-vm01"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

}


resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

output "zone_vm-01" {
  value = yandex_compute_instance.vm-01.zone
}

output "internal_ip_address_vm-01" {
  value = yandex_compute_instance.vm-01.network_interface.0.ip_address
}

output "external_ip_address_vm-01" {
  value = yandex_compute_instance.vm-01.network_interface.0.nat_ip_address
}
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "my-bucket-1q2w3e4r"
    region     = "ru-central1"
    key        = "./terraform.tfstate"
    access_key = "YCAJEuU0nHfzi4MbHMOq2bQk_"
    secret_key = "YCMcKQkucbJ3ThlyBoTEf42kfwLjLkT9FTUUUJdt"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  #  token     = "<OAuth>"
  service_account_key_file = "key.json"
  cloud_id                 = "b1g2d742rcmsdqcj615o"
  folder_id                = "b1g3jugliqbmg2eomqbj"
  zone                     = "ru-central1-a"
}

resource "yandex_storage_bucket" "my-bucket-1q2w3e4r" {
  access_key = "YCAJEuU0nHfzi4MbHMOq2bQk_" #key_id "<идентификатор статического ключа>"
  secret_key = "YCMcKQkucbJ3ThlyBoTEf42kfwLjLkT9FTUUUJdt" #secret "<секретный ключ>"
  bucket     = "my-bucket-1q2w3e4r"
}

// Create a new instances
locals {
  instance_type_w = {
    stage = "standard-v1"
    prod = "standard-v3"
  }
  instance_count_w={
    stage=1
    prod=2
  }
  instance_cpu_w={
    stage=2
    prod=4
  }
  instance_memory_w={
    stage=4
    prod=4
  }
#  instance_for_each={
#    stage=01
#    prod=11
#    prod=12
#  }
}

variable "vms" {
  type=map
  default = {
    prod={
      vm11 = {
        name="vm11-prod-fe"
        cores=4
      }
      vm12={
        name="vm12-prod-fe"
        cores=4
      }
    }
    stage={
      vm13 ={
        name="vm13-stage-fe"
        cores=2
      }
    }
  }
}

resource "yandex_compute_instance" "vm_for_each" {
  for_each = var.vms[terraform.workspace]
  name=each.value.name
  #count= 1 #each.value

  resources {
    cores  = each.value.cores
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32" #ubuntu20.04
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "yandex_compute_instance" "vm_count" {
  count=local.instance_count_w[terraform.workspace] #"${terraform.workspace == "prod" ? 2 : 1}"
  platform_id=local.instance_type_w[terraform.workspace]
  name = "vm0${count.index+1}-${terraform.workspace}"

  resources {
    cores  = local.instance_cpu_w[terraform.workspace]
    memory = local.instance_memory_w[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32" #ubuntu20.04
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



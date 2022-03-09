resource "yandex_compute_instance" "node01" {
  name                      = "node01"
  zone                      = "ru-central1-a"
  hostname                  = "node01.netology.cloud"
  allow_stopping_for_update = true

  resources {
    cores  = 8
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.centos-7-base}"
      name        = "root-node01"
      type        = "network-nvme"
      size        = "50"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default.id}"
    nat       = true
  }

  metadata = { # centos:${file("~/.ssh/id_rsa.pub")}
# C:/Users/Денис/.ssh/id_rsa
    # /home/vagrant/.ssh/id_rsa.pub
    ssh-keys = "centos:${file("C:/Users/Денис/.ssh/id_rsa.pub")}"
  }
}

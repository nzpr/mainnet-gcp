provider "google" {
  project = "main-net"
}

terraform {
  required_version = ">= 0.12"
  backend "gcs" {
    bucket = "rchain-mainnet-tfstate"
    prefix = "rootshard-hosts"
  }
}

data google_compute_network default_network {
  name = "default"
}

data google_compute_address ext_addr {
  count = var.node_count
  name = "rnode${count.index}"
  region = replace(var.zone, "/-[a-z]$/", "")
}

resource google_compute_instance host {
  count = var.node_count
  name = "rnode${count.index}"
  hostname = "node${count.index}.${var.domain}"
  machine_type = var.machine_type
  zone = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      size = var.disk_size
      type = "pd-ssd"
    }
  }

  tags = [ "rnode" ]

  network_interface {
    network = data.google_compute_network.default_network.self_link
    access_config {
      nat_ip = data.google_compute_address.ext_addr[count.index].address
    }
  }
}

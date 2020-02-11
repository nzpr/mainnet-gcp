provider "google" {
  project = "main-net"
  zone = var.zone
}

terraform {
  required_version = ">= 0.12"
  backend "gcs" {
    bucket = "rchain-mainnet-tfstate"
    prefix = "rootshard-hosts"
  }
}

data google_compute_subnetwork mainnet {
  name = "mainnet"
}

data google_compute_address rnode_ext {
  count = var.node_count
  name = "rnode-ext-${count.index}"
}

data google_compute_address rnode_int {
  count = var.node_count
  name = "rnode-int-${count.index}"
}

resource google_compute_instance host {
  count = var.node_count
  name = "rnode-${count.index}"
  hostname = "node${count.index}.${var.domain}"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      size = var.disk_size
      type = "pd-ssd"
    }
  }

  tags = [ "rnode" ]

  network_interface {
    subnetwork = data.google_compute_subnetwork.mainnet.self_link
    network_ip = data.google_compute_address.rnode_int[count.index].address
    access_config {
      nat_ip = data.google_compute_address.rnode_ext[count.index].address
    }
  }
}

provider "google" {
  project = "main-net"
}

terraform {
  required_version = ">= 0.12"
  backend "gcs" {
    bucket = "rchain-mainnet-tfstate"
    prefix = "project-common"
  }
}

data google_compute_network default_network {
  name = "default"
}

resource google_compute_firewall fw_deny_all {
  name = "deny-all"
  network = data.google_compute_network.default_network.self_link
  priority = 50000
  deny {
    protocol = "tcp"
  }
  deny {
    protocol = "udp"
  }
}

resource google_compute_firewall fw_rnode {
  name = "rnode"
  network = data.google_compute_network.default_network.self_link
  priority = 1000
  target_tags = ["rnode"]
  allow {
    protocol = "tcp"
    ports = [40400, 40401, 40403, 40404]
  }
}

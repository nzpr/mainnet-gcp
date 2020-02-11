provider "google" {
  project = "main-net"
  zone = var.zone
}

terraform {
  required_version = ">= 0.12"
  backend "gcs" {
    bucket = "rchain-mainnet-tfstate"
    prefix = "rootshard-static"
  }
}

resource google_compute_network mainnet {
  name = "mainnet"
  auto_create_subnetworks = false
}

resource google_compute_subnetwork mainnet {
  name = "mainnet"
  network = google_compute_network.mainnet.self_link
  ip_cidr_range = var.subnet
}

resource google_compute_firewall denyall {
  name = "deny-all"
  network = google_compute_network.mainnet.self_link
  priority = 50000
  deny {
    protocol = "tcp"
  }
  deny {
    protocol = "udp"
  }
}

resource google_compute_firewall rnode {
  name = "rnode"
  network = google_compute_network.mainnet.self_link
  priority = 1000
  target_tags = ["rnode"]
  allow {
    protocol = "tcp"
    ports = [40400, 40401, 40403, 40404]
  }
}

resource google_compute_address rnode_ext {
  count = var.node_count
  name = "rnode-ext-${count.index}"
  address_type = "EXTERNAL"
}

resource google_compute_address rnode_int {
  count = var.node_count
  name = "rnode-int-${count.index}"
  address_type = "INTERNAL"
  subnetwork = google_compute_subnetwork.mainnet.self_link
  address = cidrhost(google_compute_subnetwork.mainnet.ip_cidr_range, count.index + 10)
}

resource google_dns_record_set rnode_a {
  count = var.node_count
  name = "node${count.index}.${var.domain}."
  managed_zone = "root-shard"
  type = "A"
  ttl = 300
  rrdatas = [google_compute_address.rnode_ext[count.index].address]
}

data google_compute_network developer {
  project = "developer-222401"
  name = "default"
}

resource google_compute_network_peering mainnet_developer {
  name = "mainnet-developer"
  network = google_compute_network.mainnet.self_link
  peer_network = data.google_compute_network.developer.self_link
}

resource google_compute_network_peering developer_mainnet {
  name = "developer-mainnet"
  network = data.google_compute_network.developer.self_link
  peer_network = google_compute_network.mainnet.self_link
}

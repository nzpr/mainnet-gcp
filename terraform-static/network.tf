resource google_compute_network mainnet {
  name = "mainnet"
  auto_create_subnetworks = false
}

resource google_compute_subnetwork mainnet {
  name = "mainnet"
  network = google_compute_network.mainnet.self_link
  ip_cidr_range = var.subnet
}

resource google_compute_firewall default_allow {
  name = "default-allow"
  network = google_compute_network.mainnet.self_link
  priority = 50000
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = [22]
  }
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

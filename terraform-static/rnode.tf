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

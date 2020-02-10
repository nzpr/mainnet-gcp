provider "google" {
  project = "main-net"
}

terraform {
  required_version = ">= 0.12"
  backend "gcs" {
    bucket = "rchain-mainnet-tfstate"
    prefix = "rootshard-static"
  }
}

data google_compute_network default_network {
  name = "default"
}

resource google_compute_address ext_addr {
  count = var.node_count
  name = "rnode${count.index}"
  address_type = "EXTERNAL"
  region = replace(var.zone, "/-[a-z]$/", "")
}

resource google_dns_record_set dns_addr {
  count = var.node_count
  name = "node${count.index}.${var.domain}."
  managed_zone = "root-shard"
  type = "A"
  ttl = 300
  rrdatas = [google_compute_address.ext_addr[count.index].address]
}

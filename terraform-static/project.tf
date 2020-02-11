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

resource google_compute_project_metadata_item enable_oslogin {
  key = "enable-oslogin"
  value = "TRUE"
}

resource google_compute_project_metadata_item enable_serial {
  key = "serial-port-enable"
  value = "true"
}

resource google_compute_project_metadata_item enable_serial_logging {
  key = "serial-port-logging-enable"
  value = "true"
}

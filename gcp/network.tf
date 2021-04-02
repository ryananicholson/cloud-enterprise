resource "google_compute_network" "vpc_network" {
  name = "${var.org_name}-network"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.org_name}-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "ad-firewall" {
  name    = "${var.ad}-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["3389", "5986"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ad"]
}

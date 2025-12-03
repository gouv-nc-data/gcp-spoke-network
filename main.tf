locals {
  vpc-spoke-link = "projects/prj-dinum-p-hub-vpc-dcf1/global/networks/hub-network"
}

####
# vpc network
####
module "vpc" {
  source     = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-vpc?ref=v44.1.0"
  project_id = var.project_id
  name       = "vpc-${var.project_id}"

  # Subnet pour les ressources qui doivent accéder à l'on-premise (Dataproc, VMs, etc.)
  subnets = [
    {
      ip_cidr_range = var.subnet
      name          = var.subnet_name
      region        = var.region
    }
  ]

}


####
# Spoke network
####
module "hub-to-spoke-peering" {
  source        = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-vpc-peering?ref=v44.1.0"
  local_network = module.vpc.self_link
  peer_network  = local.vpc-spoke-link
  routes_config = {
    local = { export = true, import = true }
    peer  = { export = true, import = true }
  }
}

resource "google_compute_firewall" "default-allow-internal" {

  name    = "default-allow-internal"
  project = var.project_id
  network = module.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  direction = "INGRESS"

  # Autoriser le trafic depuis les ressources on-premise uniquement.
  source_ranges = [var.subnet]
}

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
  subnets = var.subnet_onprem_4_resources != "" ? [
    {
      ip_cidr_range = var.subnet_onprem_4_resources
      name          = "subnet-onprem-resources"
      region        = var.region
    }
  ] : []

  # Subnet NAT: Pool d'IPs pour Hybrid NAT (pas de ressources dedans)
  subnets_private_nat = var.subnet_onprem_4_gke != "" ? [
    {
      ip_cidr_range = var.subnet_onprem_4_gke
      name          = "subnet-nat-hybrid"
      region        = var.region
    }
  ] : []
}

resource "google_compute_router" "nat_router_hybrid" {
  count = var.subnet_onprem_4_gke != "" ? 1 : 0

  name    = "router-nat-hybrid-${var.region}"
  region  = var.region
  project = var.project_id
  network = module.vpc.name
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
  count = var.subnet_onprem_4_resources != "" ? 1 : 0

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
  source_ranges = [var.subnet_onprem_4_resources]
}

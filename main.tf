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

####
# Cloud Router pour Hybrid NAT (accès on-premise via VPN)
# Note: Le routeur pour Hybrid NAT doit être dédié (pas d'autre NAT dessus)
####
resource "google_compute_router" "nat_router_hybrid" {
  count = var.subnet_onprem_4_gke != "" && var.gke_subnet_self_link != "" ? 1 : 0

  name    = "router-nat-hybrid-${var.region}"
  region  = var.region
  project = var.project_id
  network = module.vpc.name
}

####
# Hybrid NAT pour accès on-premise via VPN/Interconnect
# Utilise les IPs du subnet PRIVATE_NAT (/28) autorisées on-premise
# S'applique au subnet GKE fourni en input (géré par le module GKE)
####
resource "google_compute_router_nat" "nat_hybrid" {
  count = var.subnet_onprem_4_gke != "" && var.gke_subnet_self_link != "" ? 1 : 0

  name    = "nat-hybrid-onprem"
  project = var.project_id
  region  = var.region
  router  = google_compute_router.nat_router_hybrid[0].name

  # Type PRIVATE pour Hybrid NAT
  type = "PRIVATE"

  # Utilise les IPs du subnet PRIVATE_NAT
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # Subnet source (GKE pods qui doivent accéder on-premise)
  # Le subnet GKE est fourni en input depuis le module GKE
  subnetwork {
    name                    = var.gke_subnet_self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  # Règle NAT pour le trafic hybride (vers VPN/Interconnect)
  rules {
    rule_number = 100
    description = "NAT vers on-premise via VPN"
    match       = "nexthop.is_hybrid"
    action {
      source_nat_active_ranges = [values(module.vpc.subnets_private_nat)[0].name]
    }
  }
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

  # Autoriser le trafic depuis les plages internes (GKE + ressources on-premise)
  source_ranges = concat(
    var.gke_ip_ranges,
    var.subnet_onprem_4_resources != "" ? [var.subnet_onprem_4_resources] : []
  )
}

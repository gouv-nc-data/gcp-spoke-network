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

  # Subnet A: Pour GKE (Pods, Services, Nœuds)
  subnets = concat(
    var.enable_gke_network ? [
      {
        ip_cidr_range = var.subnet_gke_primary_range
        name          = "subnet-gke"
        region        = var.region
        secondary_ip_ranges = {
          "pods-range" = {
            ip_cidr_range = var.subnet_gke_pods_range
          }
          "services-range" = {
            ip_cidr_range = var.subnet_gke_services_range
          }
        }
      }
    ] : [],
    var.subnet_onprem_4_resources != "" ? [
      {
        ip_cidr_range = var.subnet_onprem_4_resources
        name          = "subnet-onprem-resources"
        region        = var.region
      }
    ] : []
  )

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
# Cloud Router pour NAT Internet (public)
####
resource "google_compute_router" "nat_router_public" {
  count = var.enable_gke_network && var.enable_internet_gke ? 1 : 0

  name    = "router-nat-public-${var.region}"
  region  = var.region
  project = var.project_id
  network = module.vpc.name
}

####
# Public NAT pour accès Internet depuis les pods/resources
####
resource "google_compute_router_nat" "nat_internet" {
  count = var.enable_gke_network && var.enable_internet_gke ? 1 : 0

  name    = "nat-public-internet"
  project = var.project_id
  region  = var.region
  router  = google_compute_router.nat_router_public[0].name

  # NAT public pour l'accès Internet
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # Natter le trafic depuis le subnet GKE vers Internet
  subnetwork {
    name                    = module.vpc.subnet_self_links["${var.region}/subnet-gke"]
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

####
# Cloud Router pour Hybrid NAT (accès on-premise via VPN)
# Note: Le routeur pour Hybrid NAT doit être dédié (pas d'autre NAT dessus)
####
resource "google_compute_router" "nat_router_hybrid" {
  count = var.subnet_onprem_4_gke != "" ? 1 : 0

  name    = "router-nat-hybrid-${var.region}"
  region  = var.region
  project = var.project_id
  network = module.vpc.name
}

####
# Hybrid NAT pour accès on-premise via VPN/Interconnect
# Utilise les IPs du subnet PRIVATE_NAT (/28) autorisées on-premise
####
resource "google_compute_router_nat" "nat_hybrid" {
  count = var.subnet_onprem_4_gke != "" ? 1 : 0

  name    = "nat-hybrid-onprem"
  project = var.project_id
  region  = var.region
  router  = google_compute_router.nat_router_hybrid[0].name

  # Type PRIVATE pour Hybrid NAT
  type = "PRIVATE"

  # Utilise les IPs du subnet PRIVATE_NAT
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # Subnet source (GKE pods qui doivent accéder on-premise)
  dynamic "subnetwork" {
    for_each = var.enable_gke_network ? [1] : []
    content {
      name                    = module.vpc.subnet_self_links["${var.region}/subnet-gke"]
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }

  # Règle NAT pour le trafic hybride (vers VPN/Interconnect)
  rules {
    rule_number = 100
    description = "NAT vers on-premise via VPN"
    match       = "nexthop.is_hybrid"
    action {
      source_nat_active_ranges = [module.vpc.subnets_private_nat[0].name]
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

  # Autoriser le trafic depuis les plages internes
  source_ranges = concat(
    var.enable_gke_network ? [
      var.subnet_gke_primary_range,
      var.subnet_gke_pods_range,
      var.subnet_gke_services_range
    ] : [],
    var.subnet_onprem_4_resources != "" ? [var.subnet_onprem_4_resources] : []
  )
}

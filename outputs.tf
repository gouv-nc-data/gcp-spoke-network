output "vpc" {
  description = "VPC module outputs (contient network, subnets, etc.)"
  value       = module.vpc
}

output "vpc_name" {
  description = "Nom du VPC"
  value       = module.vpc.name
}

output "vpc_self_link" {
  description = "Self link du VPC"
  value       = module.vpc.self_link
}

output "onprem_subnet_name" {
  description = "Nom du subnet pour ressources Dataproc/VMs (accès on-premise)"
  value       = var.subnet_onprem_4_resources != "" ? "subnet-onprem-resources" : null
}

output "onprem_subnet_self_link" {
  description = "Self link du subnet on-premise"
  value       = var.subnet_onprem_4_resources != "" ? module.vpc.subnet_self_links["${var.region}/subnet-onprem-resources"] : null
}

output "hybrid_nat_subnet_range" {
  description = "Plage IP du subnet PRIVATE_NAT utilisé pour le Hybrid NAT"
  value       = var.subnet_onprem_4_gke != "" ? var.subnet_onprem_4_gke : null
}

output "router_name" {
  description = "Nom du routeur créé pour le NAT hybride"
  value       = var.subnet_onprem_4_gke != "" ? google_compute_router.nat_router_hybrid[0].name : null
}

output "nat_subnet_name" {
  description = "Nom du subnet utilisé pour le NAT hybride"
  value       = var.subnet_onprem_4_gke != "" ? values(module.vpc.subnets_private_nat)[0].name : null
}

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

# Outputs pour GKE
output "gke_subnet_name" {
  description = "Nom du subnet GKE (pour les nœuds)"
  value       = var.enable_gke_network ? "subnet-gke" : null
}

output "gke_subnet_self_link" {
  description = "Self link du subnet GKE"
  value       = var.enable_gke_network ? module.vpc.subnet_self_links["${var.region}/subnet-gke"] : null
}

output "gke_pods_range_name" {
  description = "Nom de la plage secondaire pour les pods GKE"
  value       = var.enable_gke_network ? "pods-range" : null
}

output "gke_services_range_name" {
  description = "Nom de la plage secondaire pour les services GKE"
  value       = var.enable_gke_network ? "services-range" : null
}

output "gke_pods_ip_range" {
  description = "Plage IP des pods GKE"
  value       = var.enable_gke_network ? var.subnet_gke_pods_range : null
}

output "gke_services_ip_range" {
  description = "Plage IP des services GKE"
  value       = var.enable_gke_network ? var.subnet_gke_services_range : null
}

# Output pour ressources on-premise
output "onprem_subnet_name" {
  description = "Nom du subnet pour ressources Dataproc/VMs (accès on-premise)"
  value       = var.subnet_onprem_4_resources != "" ? "subnet-onprem-resources" : null
}

output "onprem_subnet_self_link" {
  description = "Self link du subnet on-premise"
  value       = var.subnet_onprem_4_resources != "" ? module.vpc.subnet_self_links["${var.region}/subnet-onprem-resources"] : null
}

# Output pour Hybrid NAT
output "hybrid_nat_enabled" {
  description = "Indique si le Hybrid NAT est activé"
  value       = var.subnet_onprem_4_gke != ""
}

output "hybrid_nat_subnet_range" {
  description = "Plage IP du subnet PRIVATE_NAT utilisé pour le Hybrid NAT"
  value       = var.subnet_onprem_4_gke != "" ? var.subnet_onprem_4_gke : null
}
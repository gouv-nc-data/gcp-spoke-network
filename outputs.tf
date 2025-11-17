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
  value       = var.subnet_onprem_4_gke != "" && var.gke_subnet_self_link != ""
}

output "hybrid_nat_subnet_range" {
  description = "Plage IP du subnet PRIVATE_NAT utilisé pour le Hybrid NAT"
  value       = var.subnet_onprem_4_gke != "" ? var.subnet_onprem_4_gke : null
}

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

output "subnet_name" {
  description = "Nom du subnet pour ressources Dataproc/VMs (accès on-premise)"
  value       = var.subnet_name
}

output "subnet_self_link" {
  description = "Self link du subnet on-premise"
  value       = module.vpc.subnet_self_links["${var.region}/${var.subnet_name}"]
}



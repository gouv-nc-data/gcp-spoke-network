variable "project_id" {
  type        = string
  description = "id du projet"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

# variable "subnet" {
#   type        = string
#   description = "subnet autorisé par les ressource on-premise via le VPN"
# }

variable "subnet_gke_primary_range" {
  description = "Plage IP principale du subnet GKE (anciennement var.subnet)"
  type        = string
  default     = "10.10.0.0/24"
}

variable "subnet_gke_pods_range" {
  description = "Plage IP secondaire pour les PODS GKE."
  type        = string
  default     = "10.50.0.0/22"
}

variable "subnet_gke_services_range" {
  description = "Plage IP secondaire pour les SERVICES GKE."
  type        = string
  default     = "10.60.0.0/24"
}

variable "subnet_onprem_4_resources" {
  description = "Plage IP pour les ressources (Dataproc, VMs) qui accèdent on-premise. IPs autorisées côté on-premise."
  type        = string
  default     = ""
}

variable "subnet_onprem_4_gke" {
  description = "Plage IP pour le subnet PRIVATE_NAT. Pool d'IPs pour le Hybrid NAT. Doit être autorisée on-premise."
  type        = string
  default     = ""
}

variable "enable_gke_network" {
  description = "Activer les subnets GKE avec plages secondaires."
  type        = bool
  default     = false
}

variable "enable_internet_gke" {
  description = "NAT interne pour accès Internet depuis les pods/resources."
  type        = bool
  default     = true
}

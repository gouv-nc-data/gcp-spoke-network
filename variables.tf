variable "project_id" {
  type        = string
  description = "id du projet"
}

variable "region" {
  type    = string
  default = "europe-west1"
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

variable "gke_subnet_self_link" {
  description = "Self link du subnet GKE (géré par le module GKE) sur lequel appliquer le Hybrid NAT."
  type        = string
  default     = ""
}

variable "gke_ip_ranges" {
  description = "Plages IP GKE à autoriser dans le firewall : [primary_range, pods_range, services_range]"
  type        = list(string)
  default     = []
}

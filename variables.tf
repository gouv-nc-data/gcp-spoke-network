variable "project_id" {
  type        = string
  description = "id du projet"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "subnet" {
  type        = string
  description = "Plage IP pour les ressources (Dataproc, VMs) qui accèdent on-premise. IPs autorisées côté on-premise."
  default     = ""
}

variable "subnet_name" {
  type        = string
  description = "Nom du subnet"
  default     = "subnet-for-vpn"
}

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
  description = "subnet dans lequel s'executent les data proc"
}

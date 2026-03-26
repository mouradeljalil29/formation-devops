variable "region" {
  description = "Région Scaleway"
  type        = string
  default     = "pl-waw"
}

variable "zone" {
  description = "Zone Scaleway"
  type        = string
  default     = "pl-waw-2"
}

variable "access_key" {
  type = string
  sensitive = true
}

variable "secret_key" {
  type = string
  sensitive = true
}

variable "organization_id" {
  type = string
  sensitive = true
}

variable "project_id" {
  type = string
  sensitive = true
}


variable "app_name" {
  description = "Nom de l'application — utilisé comme préfixe des ressources"
  type        = string
  default     = "devops-formation"
}

variable "environment" {
  description = "Environnement cible"
  type        = string
  default     = "staging"
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "environment doit être 'staging' ou 'production'."
  }
}

variable "instance_type" {
  description = "Type d'instance Scaleway"
  type        = string
  default     = "STARDUST1-S"
}

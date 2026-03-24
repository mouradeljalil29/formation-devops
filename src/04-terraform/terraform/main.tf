terraform {
  required_version = ">= 1.5"
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.40"
    }
  }

  # State remote dans Scaleway Object Storage (compatible S3)
  # Décommenter et configurer le bucket avant le premier `terraform init`
  # backend "s3" {
  #   bucket                      = "tf-state-devops-formation"
  #   key                         = "app/terraform.tfstate"
  #   region                      = "fr-par"
  #   endpoint                    = "https://s3.fr-par.scw.cloud"
  #   skip_credentials_validation = true
  #   skip_region_validation      = true
  #   skip_requesting_account_id  = true
  # }
}

provider "scaleway" {
  zone            = var.zone
  region          = var.region
  access_key      = var.access_key
  secret_key      = var.secret_key
  organization_id = var.organization_id
  project_id      = var.project_id
}

# ------------------------------------------------------------------ #
# Instance de calcul                                                   #
# ------------------------------------------------------------------ #
resource "scaleway_instance_ip" "app" {}

resource "scaleway_instance_security_group" "app" {
  name                    = "sg-${var.app_name}"
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"

  inbound_rule {
    action = "accept"
    port   = "22"
  }

  inbound_rule {
    action = "accept"
    port   = "80"
  }

  inbound_rule {
    action = "accept"
    port   = "443"
  }
}

resource "scaleway_instance_server" "app" {
  name              = var.app_name
  type              = var.instance_type
  image             = "930a4b65-67b6-4bc5-ba51-2c55dfda7856" # Ubuntu 24.04
  ip_id             = scaleway_instance_ip.app.id
  security_group_id = scaleway_instance_security_group.app.id
  tags              = ["formation", "devops", var.environment]

  user_data = {
    cloud-init = templatefile("${path.module}/cloud-init.yml", {
      app_name = var.app_name
    })
  }
}

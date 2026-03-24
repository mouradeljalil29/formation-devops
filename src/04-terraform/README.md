# TP 5 — Provisionner l'infra avec Terraform


## Prérequis

- Un compte Scaleway avec une organisation et un projet
- Les droits IAM pour créer des instances, des registries et des buckets Object Storage

---

## 1. Configurer l'accès API Scaleway

1. Ouvrir la [console Scaleway](https://console.scaleway.com/iam/api-keys)
2. **IAM → API Keys → Generate API Key**
2. Expiration : 1 semaine (max)
3. Copier la fin du format `Terraform` pour créer le fichier `scaleway.auto.tfvars`

---

## 2. Installer Terraform

```bash
# macOS (Homebrew)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Linux (APT)
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform

# Vérifier
terraform version
```

---

## 3. Workflow Terraform

```bash
cd src/04-terraform/terraform

# Télécharger le provider Scaleway et initialiser le backend
terraform init

# Afficher le diff entre l'état désiré et l'état actuel (aucune modification)
terraform plan

# Appliquer — crée l'instance et le registry sur Scaleway
terraform apply

# Récupérer les outputs après l'apply
terraform output instance_ip
```

---

## 4. (Optionnel) Activer le state remote

Le state local (`terraform.tfstate`) est dangereux en équipe. Pour le stocker dans Scaleway Object Storage :

### 4.1 Créer le bucket

```bash
scw object bucket create name=tf-state-devops-formation region=fr-par
```

### 4.2 Décommenter le backend dans `main.tf`

```hcl
backend "s3" {
  bucket                      = "tf-state-devops-formation"
  key                         = "app/terraform.tfstate"
  region                      = "fr-par"
  endpoint                    = "https://s3.fr-par.scw.cloud"
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
}
```

Les credentials du bucket sont lus depuis les variables `SCW_ACCESS_KEY` / `SCW_SECRET_KEY` déjà exportées.

---

## 5. Nettoyage

```bash
# Détruire toutes les ressources provisionnées
terraform destroy
```

> Toujours lancer `terraform destroy` à la fin du TP pour éviter des coûts inutiles.

---

## Structure des fichiers

```
terraform/
├── main.tf          # Provider, backend, ressources principales
├── variables.tf     # Paramètres d'entrée (type, région, instance…)
├── outputs.tf       # Valeurs exportées (IP, endpoint registry)
└── cloud-init.yml   # Script d'initialisation de l'instance
```

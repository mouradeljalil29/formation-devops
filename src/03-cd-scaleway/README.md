# TP 3 — Déploiement continu sur Scaleway

Mode opératoire complet : création du compte, provisionnement de l'instance, configuration des secrets GitHub, déploiement via le pipeline CD.

---

## Prérequis

- Accès au dépôt GitHub du projet (fork ou accès collaborateur)
- Pipeline CI (`ci.yml`) passant au vert (TP 3 terminé)
- Carte bancaire pour la création du compte Scaleway (aucun débit si on reste dans les limites du free tier)

---

## Étape 1 — Générer une paire de clés SSH Ed25519

Sur votre machine locale :

```bash
# Générer la paire de clés (sans passphrase pour l'automatisation)
ssh-keygen -t ed25519 -C "github-actions-formation" -f ~/.ssh/id_ed25519_formation -N ""

# Afficher la clé publique (à copier dans Scaleway)
cat ~/.ssh/id_ed25519_formation.pub

# Afficher la clé privée (à copier dans GitHub Secrets)
cat ~/.ssh/id_ed25519_formation
```

---

## Étape 2 — Créer un compte Scaleway

1. Aller sur [console.scaleway.com](https://console.scaleway.com) → **S'inscrire** ou Se connecter
1. Choisir un compte de type "Projet personnel"
2. Renseigner adresse e-mail → valider avec le code de confirmation reçu par e-mail
2. Renseigner Prénom / Nom
3. Entrer votre adresse postale
3. Ajouter une méthode de paiement : 
    1. un prélèvement de 1€ est réalisé puis remboursé
    2. le coût total du TP sera d'environ 1€ supplémentaire (Optionnel)
4. Entrer "formation-devops" pour le nom du projet
4. Choisir "Héberger une application Web"
4. Voilà, vous êtes arrivés sur le *Dashboard projet*

---

## Étape 3 — Créer une instance Compute

1. Console → **Compute** → **CPU & GPU Instances** → **Create CPU Instance**
2. Dans Liste > Rechercher entrer : `STARDUST1-S`
3. Cliquer sur "Choisir la zone" en fin de ligne affichée
4. Choisir l'image `Ubuntu 24.04`
4. Ajouter une **Clé SSH** : coller la clé **publique** obtenue à l'étape 1 et la nommer "formation"
3. Cliquer **Create Instance** → attendre l'état `Running` (≈ 10 s)
4. Relever l'**IP publique** affichée dans "Flexible IP" → sera `INSTANCE_IP`

---

## Étape 4 — Préparer l'instance (Docker)

Se connecter à l'instance et installer Docker :

```bash
export INSTANCE_IP=<INSTANCE_IP>
ssh -i ~/.ssh/id_ed25519_formation ubuntu@$INSTANCE_IP

# Sur l'instance — ajouter le dépôt officiel Docker
# (docker-compose-plugin n'est pas dans les dépôts Ubuntu par défaut)
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker Engine + Compose v2
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker ubuntu
sudo mkdir -p /opt/app/{db,nginx}
sudo chown -R ubuntu:ubuntu /opt/app

# Vérifier
docker --version
docker compose version

# Créer le fichier `/opt/app/.env` sur l'instance avec les variables de l'application
cat > /opt/app/.env <<EOF
DB_PASSWORD=motdepassefort
APP_VERSION=local
EOF
chmod 600 /opt/app/.env
```

Déposer les fichiers `docker-compose.yml`, `init.sql` et `nginx.conf` de l'application sur l'instance :

```bash
# Depuis votre machine locale
scp -i ~/.ssh/id_ed25519_formation \
    src/app/docker-compose.yml \
    ubuntu@$INSTANCE_IP:/opt/app/docker-compose.yml
scp -i ~/.ssh/id_ed25519_formation \
    src/app/db/init.sql \
    ubuntu@$INSTANCE_IP:/opt/app/db/init.sql
scp -i ~/.ssh/id_ed25519_formation \
    src/app/nginx/nginx.conf \
    ubuntu@$INSTANCE_IP:/opt/app/nginx/nginx.conf
```

---

## Étape 5 — Configurer les environments et secrets GitHub

1. Dépôt GitHub → **Settings** → **Environments** → **New environment**
2. Créer deux environments : `staging` et `production`
3. Pour `production` : activer **Required reviewers** → ajouter votre compte → **Save protection rules**
2. Pour les deux environnements : **Add environment secret** → renseigner le nom et la valeur → **Add secret** pour les deux éléments du tableau ci-dessous :


| Secret | Valeur |
|---|---|
| `SSH_PRIVATE_KEY` | Contenu complet de `cat ~/.ssh/id_ed25519_formation` (inclure les lignes `-----BEGIN` et `-----END`) |
| `INSTANCE_IP` | IP publique de l'instance Scaleway (ex : `XX.XX.XX.XX`) |

---

## Étape 6 — Déclencher le pipeline CD

```bash
git checkout main
# Copier le fichier cd.yml
cp src/03-cd-scaleway/cd.yml .github/workflows/
git add -A
git commit -m "adding CD workflow"
git push origin main
```

**Suivi dans GitHub :**
1. Onglet **Actions** → pipeline `CD` se déclenche automatiquement
2. Job `Deploy to Staging` s'exécute → observer les logs SSH
3. Le job `Smoke test staging` envoie un `curl` sur `/api/health`
4. Job `Deploy to Production` attend votre approbation → cliquer **Review deployments** → **Approve**

---

## Vérification finale

```bash
# Vérifier que l'application répond sur l'instance
curl http://<INSTANCE_IP>/api/health
# Réponse attendue : {"status":"ok","version":"<sha-du-commit>"}

# Vérifier les conteneurs en cours d'exécution
ssh -i ~/.ssh/id_ed25519_formation ubuntu@<INSTANCE_IP> "docker ps"
```

---

## En cas d'erreur

| Symptôme | Cause probable | Solution |
|---|---|---|
| `Permission denied (publickey)` | Clé SSH non associée à l'instance | Vérifier Scaleway → SSH Keys |
| `curl: (7) Failed to connect` | Port 80 fermé | Vérifier le Security Group de l'instance |
| Job bloqué sur `Deploy to Production` | Approbation manuelle requise | Onglet Actions → Review deployments |

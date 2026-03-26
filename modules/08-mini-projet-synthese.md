---
transition: slide-left
title: Mini-projet de synthèse
layout: section
---

# Module 8 — Mini-projet de synthèse

---
level: 2
---

# Objectifs du module

- Mobiliser toutes les compétences des modules précédents
- Diagnostiquer une stack DevOps dysfonctionnelle
- Corriger couche par couche : code → CI → CD → IaC → sécurité → observabilité
- Mesurer l'impact des corrections sur les métriques DORA

---
level: 2
---

# Présentation de la stack cassée

Le répertoire `formation-devops/` contient une stack intentionnellement dégradée sur 6 dimensions :

| Couche | Problème introduit |
|---|---|
| **CI** | Pipeline rouge non corrigé depuis 3 jours |
| **CD** | Déploiement en staging qui ignore les erreurs de build |
| **IaC** | State Terraform local commité dans Git |
| **Dockerfile** | Image `node:latest` exécutée en root |
| **Secrets** | Token d'API hardcodé dans `src/config.js` |
| **Monitoring** | Aucune alerte configurée malgré un taux d'erreur > 5% |

---
level: 2
---

# Méthodologie de diagnostic

Ne pas corriger au hasard. Utiliser une approche systématique :

1. **Observer** les symptômes (logs, pipeline, métriques)
2. **Isoler** la couche impactée (code / infra / config / sécurité)
3. **Formuler** une hypothèse
4. **Corriger** de façon minimale et ciblée
5. **Valider** que le pipeline repasse vert

<div class="mt-4 bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
  💡 <strong>CALMS — Culture :</strong> blameless debugging. L'objectif est de comprendre pourquoi le système a permis ce problème, pas de trouver un fautif.
</div>

---
level: 2
---

# TP 8 — Diagnostiquer et corriger

```bash
# Cloner le répertoire de départ (état cassé)
cd formation-devops/

# 1. Observer l'état du pipeline sur GitHub Actions
#    → Identifier les jobs en échec

# 2. Lancer la stack en local
docker compose up

# 3. Inspecter les logs
docker compose logs --follow api

# 4. Ouvrir Grafana → constater le taux d'erreur élevé
#    http://localhost:3000

# 5. Scanner les secrets
gitleaks detect --source . --verbose
```

Corriger chaque problème dans l'ordre suivant (des plus critiques aux plus structurels) :
**Secret exposé → Pipeline CI rouge → Dockerfile non sécurisé → State Terraform → CD sans validation → Alerting manquant**

---
level: 2
---

# Couches à inspecter

**CI (`.github/workflows/ci.yml`):**
- Quel job échoue ? Pourquoi ?
- Le pipeline est-il configuré pour bloquer les merges ?

**Sécurité (`src/config.js`, `Dockerfile`):**
- Y a-t-il des secrets visibles dans le code ?
- L'image s'exécute-t-elle en root ? (`docker inspect` ou `id` dans le conteneur)

**IaC (`terraform/`):**
- Où est le fichier de state ? Est-il versionné ? Que contient-il ?

**Monitoring (`docker-compose.monitoring.yml`, Grafana):**
- Le taux d'erreur est-il visible ? Une alerte est-elle configurée ?

---
level: 2
---

# Correction attendue — Récapitulatif

| Problème | Correction | Principe CALMS / DORA |
|---|---|---|
| Secret hardcodé | Variable d'env via gestionnaire de secrets | Automatisation |
| Pipeline rouge ignoré | Fix + règle de branch protection | Culture |
| Image en root | `USER node` dans le Dockerfile | Culture sécurité |
| State Terraform dans Git | Remote backend S3, `.gitignore` | Partage |
| CD sans validation | Environment staging + approval gate | Lean |
| Pas d'alerte | SLO + alert rule sur error rate | Mesure |

---
level: 2
---

# Débrief collectif — DORA

Après correction, estimer les métriques DORA comparées à l'état initial :

| Métrique | Avant correction | Après correction |
|---|---|---|
| Deployment Frequency | Bloquée (CI rouge) | Restaurée |
| Lead Time | Long (merges bloqués) | Réduit (pipeline fiable) |
| Change Failure Rate | > 15% (secret exposé en prod) | < 5% |
| MTTR | Non mesuré (pas d'alerte) | < 1h (alerting configuré) |

---
level: 2
transition: slide-right
---

# Clôture de la formation

- Quels problèmes vous ont pris le plus de temps ? Pourquoi ?
- Quel principe CALMS n'était pas respecté dans la stack initiale ?
- Si vous deviez implémenter **une seule** amélioration dans votre projet actuel, laquelle choisiriez-vous ?

<div class="mt-6 bg-green-50 border-l-4 border-green-500 p-4 rounded">
  💡 Le DevOps n'est pas une destination — c'est un processus d'amélioration continue. Les métriques DORA sont votre boussole.
</div>

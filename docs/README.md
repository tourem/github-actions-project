# 📚 Documentation

Ce dossier contient toute la documentation technique du projet.

---

## 📋 Documents Disponibles

### 🔄 [GITHUB_ACTIONS.md](GITHUB_ACTIONS.md)

Guide complet sur le système CI/CD avec GitHub Actions.

**Contenu** :
- Vue d'ensemble du workflow
- Architecture du workflow partagé
- Auto-détection des modules déployables
- Descripteurs de déploiement
- Gestion des conflits de push concurrents
- Configuration et permissions

**À lire si** :
- Vous voulez comprendre comment fonctionne le CI/CD
- Vous voulez modifier le workflow
- Vous voulez réutiliser le workflow dans un autre projet
- Vous rencontrez des problèmes de build

---

### 📦 [DEPLOYMENT.md](DEPLOYMENT.md)

Guide de déploiement des applications.

**Contenu** :
- Déploiement local (depuis les sources ou GitHub Packages)
- Déploiement Docker (Docker Compose ou manuel)
- Déploiement avec descripteurs
- Configuration par environnement (dev/hml/prd)
- Monitoring et logs
- Troubleshooting

**À lire si** :
- Vous voulez déployer les applications
- Vous voulez configurer un environnement
- Vous rencontrez des problèmes de déploiement
- Vous voulez monitorer les applications

---

### 🐳 [DOCKER.md](DOCKER.md)

Guide Docker et conteneurisation.

**Contenu** :
- Architecture Docker multi-stage
- Dockerfile commun
- Images Docker (nomenclature, tags, optimisations)
- Docker Compose
- Build local
- Registry GitHub (GHCR)
- Bonnes pratiques

**À lire si** :
- Vous voulez comprendre la stratégie Docker
- Vous voulez builder des images localement
- Vous voulez publier des images sur GHCR
- Vous voulez optimiser les images
- Vous rencontrez des problèmes Docker

---

## 🎯 Par Cas d'Usage

### Je veux démarrer rapidement

1. Lire le [README principal](../README.md) - Section "Démarrage Rapide"
2. Choisir une option (Local, Docker, ou Dev)
3. Suivre les instructions

### Je veux comprendre le CI/CD

1. Lire [GITHUB_ACTIONS.md](GITHUB_ACTIONS.md) - Section "Vue d'ensemble"
2. Regarder le workflow local : `.github/workflows/ci.yml`
3. Explorer le workflow partagé sur GitHub

### Je veux déployer en production

1. Lire [DEPLOYMENT.md](DEPLOYMENT.md) - Section "Configuration par Environnement"
2. Configurer les fichiers `application-prd.yml` et `vault-prd.yml`
3. Déployer avec Docker Compose ou manuellement

### Je veux modifier le Dockerfile

1. Lire [DOCKER.md](DOCKER.md) - Section "Dockerfile Commun"
2. Cloner le repository `docker-file-common`
3. Modifier et tester localement
4. Utiliser `scripts/migrate-dockerfile.sh` pour déployer

### Je veux ajouter un nouveau module

1. Créer le module Maven avec `spring-boot-maven-plugin`
2. Ajouter les configurations Vault dans `src/main/vault/`
3. Le workflow détectera automatiquement le module
4. Vérifier avec `scripts/detect-modules.sh`

### Je rencontre un problème

1. Consulter la section "Troubleshooting" du document concerné
2. Vérifier les logs (GitHub Actions, Docker, ou application)
3. Consulter les issues GitHub du projet

---

## 📖 Structure de la Documentation

```
docs/
├── README.md                 # Ce fichier (index de la documentation)
├── GITHUB_ACTIONS.md         # Guide CI/CD complet
├── DEPLOYMENT.md             # Guide de déploiement
└── DOCKER.md                 # Guide Docker
```

---

## 🔗 Autres Ressources

### Documentation Projet

- **[README principal](../README.md)** - Vue d'ensemble du projet
- **[Scripts README](../scripts/README.md)** - Documentation des scripts

### Repositories Liés

- **Projet** : https://github.com/tourem/github-actions-project
- **Workflow Partagé** : https://github.com/tourem/github-actions-common
- **Dockerfile Commun** : https://github.com/tourem/docker-file-common

### Documentation Externe

- **GitHub Actions** : https://docs.github.com/en/actions
- **Docker** : https://docs.docker.com/
- **Spring Boot** : https://docs.spring.io/spring-boot/
- **Maven** : https://maven.apache.org/guides/

---

## 📝 Contribuer à la Documentation

Si vous trouvez des erreurs ou souhaitez améliorer la documentation :

1. Créer une issue sur GitHub
2. Proposer une Pull Request avec vos modifications
3. Suivre le format Markdown existant
4. Ajouter des exemples concrets

---

## 🎓 Glossaire

| Terme | Description |
|-------|-------------|
| **CI/CD** | Continuous Integration / Continuous Deployment |
| **GHCR** | GitHub Container Registry |
| **Workflow** | Processus automatisé GitHub Actions |
| **Descripteur** | Fichier JSON contenant les métadonnées de déploiement |
| **Module** | Sous-projet Maven indépendant |
| **Vault** | Configuration sécurisée par environnement |
| **Multi-stage build** | Technique Docker pour optimiser les images |
| **Matrix** | Stratégie GitHub Actions pour exécuter des jobs en parallèle |

---

## 📊 Diagrammes

### Architecture Globale

```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Repository                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  .github/workflows/ci.yml (28 lignes)                  │ │
│  │  ↓                                                      │ │
│  │  Appelle workflow partagé                              │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              github-actions-common (Workflow Partagé)        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  1. Auto-détection modules (detect-modules.sh)         │ │
│  │  2. Build Maven + Publish GitHub Packages              │ │
│  │  3. Build Docker + Publish GHCR                        │ │
│  │  4. Génération descripteurs (avec retry logic)         │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Artifacts Publiés                         │
│  ┌──────────────────────┐  ┌──────────────────────────────┐ │
│  │  GitHub Packages     │  │  GitHub Container Registry   │ │
│  │  (Maven)             │  │  (Docker)                    │ │
│  │  - task-api.jar      │  │  - task-api:latest           │ │
│  │  - task-batch.jar    │  │  - task-batch:latest         │ │
│  └──────────────────────┘  └──────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Flux de Déploiement

```
Developer Push
      ↓
GitHub Actions Trigger
      ↓
Auto-detect Modules → [task-api, task-batch]
      ↓
Build Maven (parallel)
      ├─→ task-api.jar
      └─→ task-batch.jar
      ↓
Build Docker (parallel)
      ├─→ task-api:latest
      └─→ task-batch:latest
      ↓
Generate Descriptors (parallel with retry)
      ├─→ deployment-descriptor-task-api-YYYYMMDD-HHMMSS.json
      └─→ deployment-descriptor-task-batch-YYYYMMDD-HHMMSS.json
      ↓
Deployment Ready ✅
```

---

## ✅ Checklist de Lecture

Pour bien démarrer avec le projet, nous recommandons de lire dans cet ordre :

- [ ] [README principal](../README.md) - Vue d'ensemble
- [ ] [GITHUB_ACTIONS.md](GITHUB_ACTIONS.md) - Comprendre le CI/CD
- [ ] [DEPLOYMENT.md](DEPLOYMENT.md) - Déployer les applications
- [ ] [DOCKER.md](DOCKER.md) - Maîtriser Docker
- [ ] [Scripts README](../scripts/README.md) - Utiliser les scripts

---

Bonne lecture ! 📖


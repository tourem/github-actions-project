# 📘 Guide Complet GitHub Actions

Ce document explique en détail le système CI/CD basé sur GitHub Actions utilisé dans ce projet.

---

## 📋 Table des Matières

- [Vue d'ensemble](#vue-densemble)
- [Architecture du Workflow](#architecture-du-workflow)
- [Auto-Détection des Modules](#auto-détection-des-modules)
- [Workflow Partagé](#workflow-partagé)
- [Descripteurs de Déploiement](#descripteurs-de-déploiement)
- [Gestion des Conflits](#gestion-des-conflits)
- [Configuration](#configuration)

---

## Vue d'ensemble

### Simplification Extrême

Le workflow local a été **réduit de 144 lignes à 28 lignes** (-80%) grâce à :

- ✅ Auto-détection des modules déployables
- ✅ Workflow partagé réutilisable
- ✅ Configuration minimale (3 inputs seulement)
- ✅ Gestion automatique des conflits

### Avant vs Après

| Aspect | Avant | Après | Amélioration |
|--------|-------|-------|--------------|
| **Lignes de code** | 144 | 28 | **-80%** |
| **Inputs requis** | 8 | 3 | **-62%** |
| **Configuration manuelle** | Modules JSON | Auto-détection | **100%** |
| **Conflits de merge** | Fréquents | Zéro | **100%** |

---

## Architecture du Workflow

### Workflow Local (`.github/workflows/ci.yml`)

Le workflow local est ultra-simplifié et appelle le workflow partagé :

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        type: choice
        options: [dev, hml, prd]
        default: dev

permissions:
  contents: write
  packages: write

jobs:
  build-and-deploy:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      java-version: '21'
      dockerfile-repo: 'tourem/docker-file-common'
      environment: ${{ github.event.inputs.environment || 'dev' }}
    secrets: inherit
```

**Seulement 3 inputs requis** :
1. `java-version` : Version de Java (ex: '21')
2. `dockerfile-repo` : Repository du Dockerfile commun
3. `environment` : Environnement cible (dev/hml/prd)

### Workflow Partagé

Le workflow partagé (`tourem/github-actions-common`) contient toute la logique :

**Jobs** :
1. **detect-modules** : Auto-détection des modules déployables
2. **build-and-publish** : Compilation et publication Maven
3. **build-docker** : Construction et publication des images Docker
4. **generate-deployment-descriptors** : Génération des descripteurs

---

## Auto-Détection des Modules

### Critères de Détection

Un module est considéré comme **déployable** s'il remplit **au moins un** des critères suivants :

| # | Critère | Description | Exemple |
|---|---------|-------------|---------|
| 1 | **spring-boot-maven-plugin** | Plugin Spring Boot présent | Application Spring Boot |
| 2 | **packaging=war/ear** | Application Java EE | Application web legacy |
| 3 | **src/main/vault/** | Configuration Vault présente | Application custom |

### Modules Ignorés

Les modules suivants sont **automatiquement ignorés** :

- ❌ JAR simples sans Spring Boot ni Vault
- ❌ Modules POM (parents/agrégateurs)
- ❌ Bibliothèques utilitaires

### Script de Détection

Le script `scripts/detect-modules.sh` analyse le `pom.xml` et génère un JSON :

```bash
./scripts/detect-modules.sh pom.xml dev
```

**Sortie** :
```json
[
  {
    "name": "task-api",
    "artifact": "com.larbotech:task-api:jar",
    "config": "com.larbotech:task-api:zip:conf-dev"
  },
  {
    "name": "task-batch",
    "artifact": "com.larbotech:task-batch:jar",
    "config": "com.larbotech:task-batch:zip:conf-dev"
  }
]
```

### Exemple de Détection

**Projet** :
```
github-actions-project/
├── task-api/          ✅ Déployable (Spring Boot + Vault)
├── task-batch/        ✅ Déployable (Spring Boot + Vault)
├── common-utils/      ❌ Non déployable (JAR simple)
└── legacy-webapp/     ✅ Déployable (WAR)
```

**Logs** :
```bash
✅ Module déployable détecté: task-api
   - Critères: spring-boot-maven-plugin, vault-config

✅ Module déployable détecté: task-batch
   - Critères: spring-boot-maven-plugin, vault-config

⚠️  Module non déployable: common-utils
   - Raison: packaging=jar, pas de critères de déploiement

✅ Module déployable détecté: legacy-webapp
   - Critères: packaging=war
```

---

## Workflow Partagé

### Repository

Le workflow partagé est hébergé sur :
```
https://github.com/tourem/github-actions-common
```

### Structure

```
github-actions-common/
├── .github/workflows/
│   └── maven-docker-build.yml    # Workflow réutilisable
├── scripts/
│   ├── detect-modules.sh         # Auto-détection
│   └── generate-deployment-descriptor.sh  # Génération descripteurs
└── README.md
```

### Utilisation

Pour utiliser le workflow partagé dans un autre projet :

```yaml
jobs:
  build:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      java-version: '21'
      dockerfile-repo: 'tourem/docker-file-common'
      environment: 'dev'
    secrets: inherit
```

### Inputs Disponibles

| Input | Description | Requis | Défaut |
|-------|-------------|--------|--------|
| `java-version` | Version de Java | ✅ | - |
| `dockerfile-repo` | Repository Dockerfile | ✅ | - |
| `environment` | Environnement (dev/hml/prd) | ❌ | `dev` |

---

## Descripteurs de Déploiement

### Qu'est-ce qu'un Descripteur ?

Un descripteur de déploiement est un fichier JSON contenant toutes les métadonnées nécessaires au déploiement :

```json
{
  "module": "task-api",
  "version": "1.0-SNAPSHOT",
  "environment": "dev",
  "timestamp": "2025-11-03T22:04:16Z",
  "docker": {
    "image": "ghcr.io/tourem/github-actions-project/task-api",
    "tag": "1.0-SNAPSHOT",
    "registry": "ghcr.io"
  },
  "maven": {
    "groupId": "com.larbotech",
    "artifactId": "task-api",
    "packaging": "jar"
  },
  "deployment": {
    "port": 8080,
    "profiles": ["dev"],
    "vault": {
      "enabled": true,
      "files": ["vault-dev.yml"]
    }
  }
}
```

### Génération Automatique

Les descripteurs sont générés automatiquement par le workflow :

**Fichiers créés** :
- `{module}/deploy/deployment-descriptor-{module}-YYYYMMDD-HHMMSS.json` (avec timestamp)
- `{module}/deploy/deployment-descriptor-{module}-latest.json` (dernière version)

**Exemple** :
```
task-api/deploy/
├── deployment-descriptor-task-api-20251103-220416.json
└── deployment-descriptor-task-api-latest.json
```

### Script de Génération

```bash
./scripts/generate-deployment-descriptor.sh task-api 1.0-SNAPSHOT dev ghcr.io
```

---

## Gestion des Conflits

### Problème : Pushs Concurrents

Lorsque plusieurs modules sont buildés en parallèle (matrice), ils tentent de pusher simultanément :

```
! [rejected]        HEAD -> main (fetch first)
error: failed to push some refs
```

### Solution : Retry avec Backoff

Le workflow implémente un mécanisme de retry automatique :

**Caractéristiques** :
- ✅ Jusqu'à **5 tentatives** de push
- ✅ **Pull et rebase** avant chaque retry
- ✅ **Délai aléatoire** (1-5s) entre les retries
- ✅ **Exit avec erreur** si toutes les tentatives échouent

**Code** :
```bash
MAX_RETRIES=5
RETRY_COUNT=0
PUSH_SUCCESS=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$PUSH_SUCCESS" = "false" ]; do
  if git push origin HEAD:main; then
    PUSH_SUCCESS=true
  else
    git pull --rebase origin main
    RETRY_COUNT=$((RETRY_COUNT + 1))
    SLEEP_TIME=$((1 + RANDOM % 5))
    sleep $SLEEP_TIME
  fi
done
```

### Scénario Typique

1. **Job task-api** et **Job task-batch** démarrent en parallèle
2. Chacun génère son descripteur avec timestamp unique
3. **task-api** push en premier → ✅ Success
4. **task-batch** tente de push → ❌ Rejected
5. **task-batch** active le retry :
   - Pull et rebase (récupère le commit de task-api)
   - Attente aléatoire (ex: 3 secondes)
   - Retry du push → ✅ Success

---

## Configuration

### Permissions Requises

Le workflow nécessite les permissions suivantes :

```yaml
permissions:
  contents: write    # Pour pusher les descripteurs
  packages: write    # Pour publier sur GitHub Packages
```

### Secrets

Les secrets sont hérités automatiquement avec `secrets: inherit` :

- `GITHUB_TOKEN` : Token automatique pour authentification

### Environnements

Le workflow supporte 3 environnements :

| Environnement | Description | Configuration Vault |
|---------------|-------------|---------------------|
| `dev` | Développement | `vault-dev.yml` |
| `hml` | Homologation | `vault-hml.yml` |
| `prd` | Production | `vault-prd.yml` |

---

## Packages Publiés

### Maven Packages (GitHub Packages)

**URL** : `https://maven.pkg.github.com/tourem/github-actions-project`

**Artifacts** :
- `com.larbotech:task-api:1.0-SNAPSHOT` (JAR)
- `com.larbotech:task-api:1.0-SNAPSHOT:zip:distribution` (ZIP)
- `com.larbotech:task-api:1.0-SNAPSHOT:zip:conf-dev` (Config dev)
- `com.larbotech:task-batch:1.0-SNAPSHOT` (JAR)
- `com.larbotech:task-batch:1.0-SNAPSHOT:zip:distribution` (ZIP)
- `com.larbotech:task-batch:1.0-SNAPSHOT:zip:conf-dev` (Config dev)

### Docker Images (GHCR)

**Registry** : `ghcr.io`

**Images** :
- `ghcr.io/tourem/github-actions-project/task-api:latest`
- `ghcr.io/tourem/github-actions-project/task-api:1.0-SNAPSHOT`
- `ghcr.io/tourem/github-actions-project/task-batch:latest`
- `ghcr.io/tourem/github-actions-project/task-batch:1.0-SNAPSHOT`

---

## Avantages du Système

| Aspect | Avantage |
|--------|----------|
| **Simplicité** | Workflow de 28 lignes seulement |
| **Automatisation** | Auto-détection des modules |
| **Réutilisabilité** | Workflow partagé entre projets |
| **Robustesse** | Gestion automatique des conflits |
| **Traçabilité** | Descripteurs de déploiement horodatés |
| **Optimisation** | Pas de build inutile pour les bibliothèques |

---

## Liens Utiles

- **Workflow Local** : `.github/workflows/ci.yml`
- **Workflow Partagé** : https://github.com/tourem/github-actions-common
- **Actions** : https://github.com/tourem/github-actions-project/actions
- **Packages** : https://github.com/tourem/github-actions-project/packages


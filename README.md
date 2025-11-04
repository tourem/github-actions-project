# 🚀 GitHub Actions Project - Task Management System

[![CI/CD Pipeline](https://github.com/tourem/github-actions-project/actions/workflows/ci.yml/badge.svg)](https://github.com/tourem/github-actions-project/actions/workflows/ci.yml)
[![GitHub Packages](https://img.shields.io/badge/GitHub-Packages-blue)](https://github.com/tourem/github-actions-project/packages)
[![Docker](https://img.shields.io/badge/Docker-GHCR-blue)](https://github.com/tourem/github-actions-project/pkgs/container/github-actions-project)

Projet Maven multi-modules avec Spring Boot 3 et JDK 21, démontrant les meilleures pratiques de CI/CD avec GitHub Actions.

---

## 📋 Table des Matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Modules](#-modules)
- [Démarrage Rapide](#-démarrage-rapide)
- [CI/CD avec GitHub Actions](#-cicd-avec-github-actions)
- [Scripts Disponibles](#-scripts-disponibles)
- [Documentation](#-documentation)
- [Développement](#-développement)

---

## 🎯 Vue d'ensemble

Ce projet est un système de gestion de tâches composé de deux modules indépendants :

- **task-api** : API REST pour la gestion des tâches (Port 8080)
- **task-batch** : Batch planifié qui crée automatiquement des tâches (Port 8081)

### Technologies

| Composant | Technologie | Version |
|-----------|-------------|---------|
| **Langage** | Java | JDK 21 |
| **Framework** | Spring Boot | 3.2.0 |
| **Build** | Maven | 3.x |
| **Base de données** | H2 | In-Memory |
| **Conteneurisation** | Docker | Latest |
| **CI/CD** | GitHub Actions | - |
| **Registry** | GitHub Packages & GHCR | - |

---

## 🏗️ Architecture

```
github-actions-project/
├── .github/
│   └── workflows/
│       └── ci.yml                    # Workflow CI/CD ultra-simplifié (28 lignes)
├── scripts/                          # Scripts utilitaires
│   ├── detect-modules.sh             # Auto-détection des modules déployables
│   ├── generate-deployment-descriptor.sh  # Génération des descripteurs
│   ├── deploy-complete-solution.sh   # Déploiement complet
│   ├── deploy-github-actions-common.sh    # Déploiement workflow partagé
│   ├── deploy-updated-workflow.sh    # Mise à jour workflow partagé
│   └── migrate-dockerfile.sh         # Migration Dockerfile
├── docs/                             # Documentation complète
│   ├── GITHUB_ACTIONS.md             # Guide GitHub Actions
│   ├── DEPLOYMENT.md                 # Guide de déploiement
│   └── DOCKER.md                     # Guide Docker
├── task-api/                         # Module API REST
│   ├── src/main/
│   │   ├── java/                     # Code source
│   │   ├── resources/                # Configuration
│   │   ├── scripts/                  # Scripts start/stop
│   │   ├── assembly/                 # Configuration assembly
│   │   └── vault/                    # Configuration Vault par environnement
│   ├── deploy/                       # Descripteurs de déploiement
│   └── pom.xml
├── task-batch/                       # Module Batch
│   ├── src/main/
│   │   ├── java/                     # Code source
│   │   ├── resources/                # Configuration
│   │   ├── scripts/                  # Scripts start/stop
│   │   ├── assembly/                 # Configuration assembly
│   │   └── vault/                    # Configuration Vault par environnement
│   ├── deploy/                       # Descripteurs de déploiement
│   └── pom.xml
├── pom.xml                           # POM parent
├── clean-packages.sh                 # Nettoyage des packages GitHub
└── docker-compose.yml                # Orchestration Docker
```

---

## 📦 Modules

### 1. Task API (Port 8080)

API REST exposant des endpoints pour la gestion des tâches.

#### Endpoints Principaux

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/tasks` | Récupère toutes les tâches |
| `GET` | `/api/tasks/stats` | Récupère les statistiques |
| `POST` | `/api/tasks` | Crée une nouvelle tâche |

#### Exemple d'utilisation

```bash
# Créer une tâche
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","description":"Ma tâche","status":"PENDING"}'

# Récupérer toutes les tâches
curl http://localhost:8080/api/tasks

# Statistiques
curl http://localhost:8080/api/tasks/stats
```

#### Base de données
- H2 en mémoire : `jdbc:h2:mem:taskdb`
- Console H2 : http://localhost:8080/h2-console

---

### 2. Task Batch (Port 8081)

Batch planifié qui s'exécute automatiquement toutes les 30 minutes.

#### Fonctionnalités
- ⏰ Planification via cron : `0 0/30 * * * ?`
- 🔄 Appelle l'API pour créer des tâches automatiquement
- 📊 Enregistre l'historique des exécutions

#### Base de données
- H2 en mémoire : `jdbc:h2:mem:batchdb`
- Console H2 : http://localhost:8081/h2-console

---

## 🚀 Démarrage Rapide

### Prérequis

- **JDK 21** installé
- **Maven 3.x** installé
- **Docker** (optionnel, pour conteneurisation)

### Option 1 : Build et Exécution Locale

```bash
# 1. Cloner le projet
git clone https://github.com/tourem/github-actions-project.git
cd github-actions-project

# 2. Compiler le projet
mvn clean package

# 3. Déployer l'API
unzip task-api/target/task-api-1.0-SNAPSHOT.zip
cd task-api
./bin/start.sh

# 4. Déployer le Batch (dans un autre terminal)
unzip task-batch/target/task-batch-1.0-SNAPSHOT.zip
cd task-batch
./bin/start.sh
```

### Option 2 : Docker Compose

```bash
# Démarrer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter les services
docker-compose down
```

### Option 3 : Mode Développement

```bash
# Terminal 1 - API
cd task-api
mvn spring-boot:run

# Terminal 2 - Batch
cd task-batch
mvn spring-boot:run
```

---

## 🔄 CI/CD avec GitHub Actions

### Workflow Ultra-Simplifié

Le projet utilise un workflow GitHub Actions **ultra-simplifié** (28 lignes) qui :

✅ Auto-détecte les modules déployables  
✅ Compile et teste le projet  
✅ Construit les images Docker  
✅ Publie vers GitHub Packages (Maven)  
✅ Publie vers GitHub Container Registry (Docker)  
✅ Génère les descripteurs de déploiement  
✅ Gère les pushs concurrents avec retry automatique  

### Configuration Minimale

<augment_code_snippet path=".github/workflows/ci.yml" mode="EXCERPT">
````yaml
name: CI/CD Pipeline

on:
  push:
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
````
</augment_code_snippet>

### Auto-Détection des Modules Déployables

Le workflow détecte automatiquement les modules déployables selon ces critères :

| Critère | Description |
|---------|-------------|
| ✅ **spring-boot-maven-plugin** | Plugin Spring Boot présent dans le POM |
| ✅ **packaging=war/ear** | Application Java EE |
| ✅ **src/main/vault/** | Configuration Vault présente |

Les bibliothèques JAR simples sont **automatiquement ignorées**.

### Packages Publiés

#### Maven Packages (GitHub Packages)
```
https://maven.pkg.github.com/tourem/github-actions-project
```

- `com.larbotech:task-api:1.0-SNAPSHOT`
- `com.larbotech:task-batch:1.0-SNAPSHOT`

#### Docker Images (GHCR)
```
ghcr.io/tourem/github-actions-project/task-api:latest
ghcr.io/tourem/github-actions-project/task-batch:latest
```

---

## 🛠️ Scripts Disponibles

Tous les scripts sont dans le dossier `scripts/` :

| Script | Description |
|--------|-------------|
| `detect-modules.sh` | Auto-détecte les modules Maven déployables |
| `generate-deployment-descriptor.sh` | Génère les descripteurs de déploiement JSON |
| `deploy-complete-solution.sh` | Déploie la solution complète GitHub Actions |
| `deploy-github-actions-common.sh` | Déploie le workflow partagé |
| `deploy-updated-workflow.sh` | Met à jour le workflow partagé |
| `migrate-dockerfile.sh` | Migre le Dockerfile vers le repo distant |

### Exemples d'utilisation

```bash
# Auto-détecter les modules
./scripts/detect-modules.sh pom.xml dev

# Générer un descripteur de déploiement
./scripts/generate-deployment-descriptor.sh task-api 1.0-SNAPSHOT dev ghcr.io

# Déployer la solution complète
./scripts/deploy-complete-solution.sh
```

---

## 📚 Documentation

Documentation complète disponible dans le dossier `docs/` :

- **[GITHUB_ACTIONS.md](docs/GITHUB_ACTIONS.md)** - Guide complet GitHub Actions
- **[DEPLOYMENT.md](docs/DEPLOYMENT.md)** - Guide de déploiement
- **[DOCKER.md](docs/DOCKER.md)** - Guide Docker et conteneurisation

---

## 💻 Développement

### Structure des Packages

**task-api:**
- `controller` : Contrôleurs REST
- `service` : Logique métier
- `repository` : Accès aux données
- `model` : Entités JPA
- `dto` : Objets de transfert

**task-batch:**
- `scheduler` : Jobs planifiés
- `service` : Services (API client, batch execution)
- `model` : Entités JPA
- `dto` : Objets de transfert
- `config` : Configuration Spring

### Compiler un Module Spécifique

```bash
# API uniquement
mvn clean package -pl task-api

# Batch uniquement
mvn clean package -pl task-batch
```

### Tests

```bash
# Exécuter tous les tests
mvn test

# Tests d'un module spécifique
mvn test -pl task-api
```

---

## 🔗 Liens Utiles

- **Repository** : https://github.com/tourem/github-actions-project
- **Workflow Partagé** : https://github.com/tourem/github-actions-common
- **Dockerfile Commun** : https://github.com/tourem/docker-file-common
- **Actions** : https://github.com/tourem/github-actions-project/actions
- **Packages** : https://github.com/tourem/github-actions-project/packages

---

## 📝 Licence

Ce projet est un exemple de démonstration des meilleures pratiques CI/CD avec GitHub Actions.


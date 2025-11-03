# 🚀 Stratégie de Migration Jenkins → GitHub Actions

## 📊 Analyse du Jenkinsfile

### Ce que demande Jenkins aux équipes

Le Jenkinsfile demande **uniquement** :

```groovy
job_pipeline.execute(
    jfrog: true,
    mavenWithNPM: true,
    npmFixConfig: false,
    projectType: 'awt',
    javaVersion: 17,
    mavenVersion: 3.9,
    jenkinsNodeLabel: 'ocs',
    mavenPom: 'pom.xml',
    CD: 'db-intranet-deploy',
    deployModule: 'dacgestion_backend',
    dockerBuilds: [
        backend_spring: [
            deployModule: 'dacgestion_backend',
            CD: 'db-intranet-deploy',
            imageTemplateRepo: [
                url: 'https://sgithub.fr.world.socgen/X-Blocks/xbl.sofa.awt-docker-spring',
                branch: 'main'
            ],
            buildArgs: [
                JAVA_VERSION: '17',
                ARTIFACT_REFERENCE: 'com.socgen.digital.agence:dacgestion_backend:jar:${version}',
                CONF_REFERENCE: 'com.socgen.digital.agence:dacgestion_backend:zip:${version}:conf-secrets-dev'
            ],
            dockerOptions: '--no-cache --pull'
        ]
    ]
)
```

### Informations Fournies par les Équipes

| Information | Exemple | Description |
|-------------|---------|-------------|
| `javaVersion` | `17` | Version de Java |
| `mavenVersion` | `3.9` | Version de Maven |
| `projectType` | `awt` | Type de projet |
| `mavenPom` | `pom.xml` | Chemin du POM |
| `deployModule` | `dacgestion_backend` | Module à déployer |
| `dockerBuilds` | `[...]` | Configuration des builds Docker |
| `imageTemplateRepo.url` | `https://...` | URL du repository Dockerfile |
| `imageTemplateRepo.branch` | `main` | Branche du Dockerfile |
| `buildArgs.JAVA_VERSION` | `17` | Version Java pour Docker |
| `buildArgs.ARTIFACT_REFERENCE` | `com.socgen:app:jar:${version}` | Référence Maven du JAR |
| `buildArgs.CONF_REFERENCE` | `com.socgen:app:zip:${version}:conf` | Référence Maven de la config |

### ❌ Ce que Jenkins NE demande PAS

- ❌ URL du registry Maven (`maven.pkg.github.com`)
- ❌ URL du registry Docker (`ghcr.io`)
- ❌ Credentials GitHub
- ❌ Configuration des tags Docker
- ❌ Configuration du cache
- ❌ Configuration des artifacts

**Tout cela est géré par le pipeline partagé Jenkins !**

---

## 🎯 Stratégie GitHub Actions

### Principe : Même Philosophie que Jenkins

1. ✅ **Workflow réutilisable** dans `github-actions-common`
2. ✅ Les équipes fournissent **uniquement** les informations métier
3. ✅ Toute la logique technique est dans le workflow partagé
4. ✅ Les équipes appellent le workflow avec des inputs simples

### Architecture Proposée

```
Repository: tourem/github-actions-common
├── .github/workflows/
│   └── maven-docker-build.yml          ← Workflow réutilisable
└── README.md

Repository: tourem/github-actions-project (équipe)
├── .github/workflows/
│   └── ci.yml                          ← Appelle le workflow partagé
├── pom.xml
└── src/
```

---

## 📝 Configuration pour les Équipes

### Fichier `.github/workflows/ci.yml` (Projet d'Équipe)

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  build-and-deploy:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      # Configuration Maven
      java-version: '21'
      maven-version: '3.9'
      maven-pom: 'pom.xml'
      
      # Configuration Docker
      dockerfile-repo: 'tourem/docker-file-common'
      dockerfile-branch: 'main'
      
      # Modules à builder
      docker-modules: |
        [
          {
            "name": "task-api",
            "artifact": "com.larbotech:task-api:jar",
            "config": "com.larbotech:task-api:zip:distribution"
          },
          {
            "name": "task-batch",
            "artifact": "com.larbotech:task-batch:jar",
            "config": "com.larbotech:task-batch:zip:distribution"
          }
        ]
    secrets: inherit
```

**C'est tout ! Les équipes ne fournissent que ça.**

---

## 🔧 Workflow Réutilisable

### Responsabilités du Workflow Partagé

Le workflow `maven-docker-build.yml` gère automatiquement :

1. ✅ **Maven Build**
   - Setup Java
   - Setup Maven
   - Cache des dépendances
   - Build et tests
   - Publication vers GitHub Packages

2. ✅ **Docker Build**
   - Checkout du Dockerfile depuis le repository partagé
   - Extraction de la version Maven
   - Build des images Docker
   - Tagging automatique (branch, sha, latest, version)
   - Push vers GitHub Container Registry (GHCR)

3. ✅ **Configuration Automatique**
   - Registry Maven : `maven.pkg.github.com/{owner}/{repo}`
   - Registry Docker : `ghcr.io/{owner}/{repo}/{module}`
   - Credentials : `secrets.GITHUB_TOKEN`
   - Tags : Calculés automatiquement

---

## 📊 Comparaison Jenkins vs GitHub Actions

| Aspect | Jenkins | GitHub Actions |
|--------|---------|----------------|
| **Configuration équipe** | `Jenkinsfile` | `.github/workflows/ci.yml` |
| **Pipeline partagé** | `job_pipeline.execute()` | `uses: tourem/github-actions-common/...` |
| **Informations demandées** | Java version, modules, Dockerfile repo | **Identique** |
| **Registry Maven** | ❌ Non demandé | ❌ Non demandé (auto) |
| **Registry Docker** | ❌ Non demandé | ❌ Non demandé (auto) |
| **Credentials** | ❌ Non demandé | ❌ Non demandé (auto) |
| **Complexité pour équipe** | ⭐ Faible | ⭐ Faible |

---

## 🎯 Avantages de cette Approche

### Pour les Équipes

1. ✅ **Simplicité** : Configuration minimale (comme Jenkins)
2. ✅ **Pas de connaissance GitHub Actions** requise
3. ✅ **Pas de gestion des credentials**
4. ✅ **Pas de configuration des registries**
5. ✅ **Migration facile** : Mapping 1:1 avec Jenkinsfile

### Pour la Plateforme

1. ✅ **Centralisation** : Un seul workflow à maintenir
2. ✅ **Cohérence** : Tous les projets utilisent la même logique
3. ✅ **Évolution** : Mise à jour centralisée
4. ✅ **Bonnes pratiques** : Appliquées automatiquement

---

## 📋 Mapping Jenkinsfile → GitHub Actions

| Jenkinsfile | GitHub Actions Input | Valeur Auto |
|-------------|---------------------|-------------|
| `javaVersion: 17` | `java-version: '17'` | - |
| `mavenVersion: 3.9` | `maven-version: '3.9'` | - |
| `mavenPom: 'pom.xml'` | `maven-pom: 'pom.xml'` | - |
| `imageTemplateRepo.url` | `dockerfile-repo: 'owner/repo'` | - |
| `imageTemplateRepo.branch` | `dockerfile-branch: 'main'` | - |
| `buildArgs.ARTIFACT_REFERENCE` | `artifact: 'groupId:artifactId:jar'` | - |
| `buildArgs.CONF_REFERENCE` | `config: 'groupId:artifactId:zip:classifier'` | - |
| *(non spécifié)* | - | `maven.pkg.github.com/{owner}/{repo}` |
| *(non spécifié)* | - | `ghcr.io/{owner}/{repo}/{module}` |
| *(non spécifié)* | - | `secrets.GITHUB_TOKEN` |

---

## 🚀 Plan de Migration

### Phase 1 : Création du Repository Partagé

1. Créer `tourem/github-actions-common`
2. Créer le workflow réutilisable `maven-docker-build.yml`
3. Documenter les inputs
4. Tester avec un projet pilote

### Phase 2 : Migration du Projet Actuel

1. Simplifier `.github/workflows/ci.yml`
2. Appeler le workflow partagé
3. Tester le build complet
4. Valider les images Docker

### Phase 3 : Migration des Autres Projets

1. Créer un guide de migration
2. Fournir un template `.github/workflows/ci.yml`
3. Accompagner les équipes
4. Migrer projet par projet

---

## 📁 Structure des Repositories

### Repository Partagé : `github-actions-common`

```
github-actions-common/
├── .github/workflows/
│   ├── maven-docker-build.yml          ← Workflow réutilisable principal
│   └── maven-build-only.yml            ← Workflow sans Docker (optionnel)
├── README.md                           ← Documentation
├── USAGE.md                            ← Guide d'utilisation
└── examples/
    ├── simple-project.yml              ← Exemple simple
    ├── multi-module.yml                ← Exemple multi-module
    └── custom-dockerfile.yml           ← Exemple Dockerfile custom
```

### Repository Équipe : `github-actions-project`

```
github-actions-project/
├── .github/workflows/
│   └── ci.yml                          ← Appelle le workflow partagé
├── pom.xml
├── task-api/
└── task-batch/
```

---

## ✅ Checklist de Migration

### Pour la Plateforme

- [ ] Créer le repository `github-actions-common`
- [ ] Créer le workflow réutilisable `maven-docker-build.yml`
- [ ] Créer la documentation (README, USAGE)
- [ ] Créer des exemples
- [ ] Tester avec un projet pilote
- [ ] Créer un guide de migration pour les équipes

### Pour les Équipes

- [ ] Lire la documentation
- [ ] Copier le template `.github/workflows/ci.yml`
- [ ] Adapter les inputs (Java version, modules, etc.)
- [ ] Tester le workflow
- [ ] Supprimer l'ancien Jenkinsfile (après validation)

---

**Date** : 2025-11-03  
**Version** : 1.0  
**Status** : Proposition de stratégie


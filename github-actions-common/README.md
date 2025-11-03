# 🚀 GitHub Actions Common - Workflows Réutilisables

Repository centralisé pour les workflows GitHub Actions partagés entre les projets.

## 📋 Workflows Disponibles

### 1. `maven-docker-build.yml`

Workflow réutilisable pour builder et déployer des applications Maven avec Docker.

**Fonctionnalités** :
- ✅ Build Maven avec cache des dépendances
- ✅ Tests automatiques
- ✅ Publication vers GitHub Packages (Maven)
- ✅ Build d'images Docker multi-modules
- ✅ Push vers GitHub Container Registry (GHCR)
- ✅ Tagging automatique (branch, sha, latest, version)
- ✅ Support de Dockerfile externe

---

## 🎯 Utilisation

### Configuration Minimale

Créez un fichier `.github/workflows/ci.yml` dans votre projet :

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
      
      # Configuration Dockerfile
      dockerfile-repo: 'tourem/docker-file-common'
      dockerfile-branch: 'main'
      
      # Modules Docker
      docker-modules: |
        [
          {
            "name": "my-app",
            "artifact": "com.example:my-app:jar",
            "config": "com.example:my-app:zip:distribution"
          }
        ]
    
    secrets: inherit
```

**C'est tout ! Aucune configuration supplémentaire nécessaire.**

---

## 📝 Inputs

### Obligatoires

| Input | Type | Description | Exemple |
|-------|------|-------------|---------|
| `java-version` | string | Version de Java | `'21'`, `'17'`, `'11'` |
| `dockerfile-repo` | string | Repository du Dockerfile | `'tourem/docker-file-common'` |
| `docker-modules` | string (JSON) | Modules à builder | Voir exemples ci-dessous |

### Optionnels

| Input | Type | Défaut | Description |
|-------|------|--------|-------------|
| `maven-version` | string | `'3.9'` | Version de Maven |
| `maven-pom` | string | `'pom.xml'` | Chemin du POM |
| `dockerfile-branch` | string | `'main'` | Branche du Dockerfile |
| `skip-tests` | boolean | `false` | Ignorer les tests Maven |
| `docker-build-enabled` | boolean | `true` | Activer le build Docker |
| `maven-registry` | string | *(auto)* | URL du registry Maven |
| `docker-registry` | string | *(auto)* | URL du registry Docker |

---

## 📊 Format `docker-modules`

Le paramètre `docker-modules` est un tableau JSON avec les propriétés suivantes :

```json
[
  {
    "name": "nom-du-module",
    "artifact": "groupId:artifactId:type",
    "config": "groupId:artifactId:type:classifier"
  }
]
```

### Propriétés

| Propriété | Description | Exemple |
|-----------|-------------|---------|
| `name` | Nom du module (utilisé pour l'image Docker) | `"task-api"` |
| `artifact` | Référence Maven du JAR (sans version) | `"com.larbotech:task-api:jar"` |
| `config` | Référence Maven du ZIP de config (sans version) | `"com.larbotech:task-api:zip:distribution"` |

**Note** : La version est ajoutée automatiquement depuis le POM Maven.

---

## 📚 Exemples

### Exemple 1 : Application Simple (1 module)

```yaml
jobs:
  build:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      java-version: '17'
      dockerfile-repo: 'tourem/docker-file-common'
      docker-modules: |
        [
          {
            "name": "my-app",
            "artifact": "com.example:my-app:jar",
            "config": "com.example:my-app:zip:conf"
          }
        ]
    secrets: inherit
```

### Exemple 2 : Application Multi-Modules

```yaml
jobs:
  build:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      java-version: '21'
      dockerfile-repo: 'tourem/docker-file-common'
      docker-modules: |
        [
          {
            "name": "backend",
            "artifact": "com.example:backend:jar",
            "config": "com.example:backend:zip:distribution"
          },
          {
            "name": "batch",
            "artifact": "com.example:batch:jar",
            "config": "com.example:batch:zip:distribution"
          },
          {
            "name": "worker",
            "artifact": "com.example:worker:jar",
            "config": "com.example:worker:zip:distribution"
          }
        ]
    secrets: inherit
```

### Exemple 3 : Avec Déclenchement Manuel

```yaml
on:
  push:
    branches: [main, develop]
  workflow_dispatch:
    inputs:
      dockerfile_branch:
        description: 'Dockerfile branch'
        default: 'main'

jobs:
  build:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      java-version: '21'
      dockerfile-repo: 'tourem/docker-file-common'
      dockerfile-branch: ${{ github.event.inputs.dockerfile_branch || 'main' }}
      docker-modules: |
        [
          {
            "name": "my-app",
            "artifact": "com.example:my-app:jar",
            "config": "com.example:my-app:zip:conf"
          }
        ]
    secrets: inherit
```

### Exemple 4 : Build Maven Seulement (Sans Docker)

```yaml
jobs:
  build:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      java-version: '17'
      dockerfile-repo: 'tourem/docker-file-common'
      docker-build-enabled: false
      docker-modules: '[]'
    secrets: inherit
```

---

## 🔧 Configuration Automatique

Le workflow configure automatiquement :

### Maven Registry

**Par défaut** : `https://maven.pkg.github.com/{owner}/{repo}`

**Exemple** : Pour le repository `tourem/my-project` :
```
https://maven.pkg.github.com/tourem/my-project
```

### Docker Registry

**Par défaut** : `ghcr.io/{owner}/{repo}/{module}`

**Exemple** : Pour le repository `tourem/my-project` et le module `backend` :
```
ghcr.io/tourem/my-project/backend
```

### Tags Docker

Les tags suivants sont générés automatiquement :

| Tag | Description | Exemple |
|-----|-------------|---------|
| `{branch}` | Nom de la branche | `main`, `develop` |
| `{branch}-{sha}` | Branche + SHA court | `main-abc123d` |
| `latest` | Tag latest (seulement sur branche par défaut) | `latest` |
| `{version}` | Version Maven | `1.0-SNAPSHOT` |

**Exemple complet** pour un push sur `main` avec version `1.0.0` :
```
ghcr.io/tourem/my-project/backend:main
ghcr.io/tourem/my-project/backend:main-abc123d
ghcr.io/tourem/my-project/backend:latest
ghcr.io/tourem/my-project/backend:1.0.0
```

---

## 📦 Outputs

Le workflow expose les outputs suivants :

| Output | Description | Exemple |
|--------|-------------|---------|
| `version` | Version Maven du projet | `1.0-SNAPSHOT` |
| `docker-images` | Liste des images Docker buildées | `ghcr.io/tourem/my-project/backend:1.0.0` |

### Utilisation des Outputs

```yaml
jobs:
  build:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      # ... inputs ...
    secrets: inherit
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: |
          echo "Version: ${{ needs.build.outputs.version }}"
          echo "Images: ${{ needs.build.outputs.docker-images }}"
```

---

## 🔐 Secrets

Le workflow utilise automatiquement `secrets.GITHUB_TOKEN` fourni par GitHub Actions.

**Aucun secret supplémentaire n'est nécessaire** si vous utilisez :
- GitHub Packages pour Maven
- GitHub Container Registry (GHCR) pour Docker

---

## 🎯 Mapping Jenkinsfile → GitHub Actions

| Jenkinsfile | GitHub Actions |
|-------------|----------------|
| `javaVersion: 17` | `java-version: '17'` |
| `mavenVersion: 3.9` | `maven-version: '3.9'` |
| `mavenPom: 'pom.xml'` | `maven-pom: 'pom.xml'` |
| `imageTemplateRepo.url` | `dockerfile-repo: 'owner/repo'` |
| `imageTemplateRepo.branch` | `dockerfile-branch: 'main'` |
| `buildArgs.ARTIFACT_REFERENCE` | `artifact: 'groupId:artifactId:jar'` |
| `buildArgs.CONF_REFERENCE` | `config: 'groupId:artifactId:zip:classifier'` |

---

## 📚 Documentation Complète

- [Guide de Migration Jenkins → GitHub Actions](../MIGRATION_STRATEGY.md)
- [Exemples Complets](./examples/)
- [FAQ](./FAQ.md)

---

## 🤝 Support

Pour toute question ou problème :
1. Consulter la [documentation](./USAGE.md)
2. Vérifier les [exemples](./examples/)
3. Créer une issue sur ce repository

---

**Maintenu par** : DevOps Team  
**Version** : 1.0  
**Dernière mise à jour** : 2025-11-03


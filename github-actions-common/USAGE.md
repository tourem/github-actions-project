# 📖 Guide d'Utilisation - GitHub Actions Common

Guide détaillé pour utiliser les workflows réutilisables.

---

## 🚀 Démarrage Rapide

### Étape 1 : Créer le Fichier Workflow

Dans votre projet, créez `.github/workflows/ci.yml` :

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]

jobs:
  build:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      java-version: '21'
      dockerfile-repo: 'tourem/docker-file-common'
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

### Étape 2 : Adapter la Configuration

Modifiez les valeurs selon votre projet :

1. **Java version** : `'17'`, `'21'`, etc.
2. **Modules** : Ajoutez vos modules dans `docker-modules`
3. **Artifact references** : Utilisez vos `groupId:artifactId`

### Étape 3 : Commit et Push

```bash
git add .github/workflows/ci.yml
git commit -m "feat: add GitHub Actions CI/CD"
git push origin main
```

**C'est tout !** Le workflow s'exécute automatiquement.

---

## 📝 Configuration Détaillée

### Format des Modules Docker

Chaque module dans `docker-modules` doit avoir :

```json
{
  "name": "nom-du-module",
  "artifact": "groupId:artifactId:type",
  "config": "groupId:artifactId:type:classifier"
}
```

#### Propriété `name`

**Description** : Nom du module, utilisé pour :
- Le nom de l'image Docker
- Les logs
- Les artifacts

**Format** : Chaîne de caractères (kebab-case recommandé)

**Exemples** :
```json
"name": "task-api"
"name": "task-batch"
"name": "backend-service"
```

#### Propriété `artifact`

**Description** : Référence Maven du JAR (sans version)

**Format** : `groupId:artifactId:type`

**Exemples** :
```json
"artifact": "com.larbotech:task-api:jar"
"artifact": "com.example:backend:jar"
"artifact": "org.mycompany:worker:jar"
```

**Note** : La version est ajoutée automatiquement depuis le POM.

#### Propriété `config`

**Description** : Référence Maven du ZIP de configuration (sans version)

**Format** : `groupId:artifactId:type:classifier`

**Exemples** :
```json
"config": "com.larbotech:task-api:zip:distribution"
"config": "com.example:backend:zip:conf"
"config": "org.mycompany:worker:zip:config-secrets-dev"
```

**Note** : Le classifier est optionnel mais recommandé.

---

## 🎯 Cas d'Usage

### Cas 1 : Application Simple (1 Module)

**Contexte** : Application Spring Boot avec un seul module.

**Configuration** :

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

**Résultat** :
- Build Maven de `my-app`
- Image Docker : `ghcr.io/{owner}/{repo}/my-app:latest`

---

### Cas 2 : Application Multi-Modules (Backend + Batch)

**Contexte** : Application avec un backend API et un batch.

**Configuration** :

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
          }
        ]
    secrets: inherit
```

**Résultat** :
- Build Maven de `backend` et `batch`
- Images Docker :
  - `ghcr.io/{owner}/{repo}/backend:latest`
  - `ghcr.io/{owner}/{repo}/batch:latest`

---

### Cas 3 : Avec Déclenchement Manuel

**Contexte** : Permettre de choisir la branche du Dockerfile manuellement.

**Configuration** :

```yaml
on:
  push:
    branches: [main, develop]
  workflow_dispatch:
    inputs:
      dockerfile_branch:
        description: 'Dockerfile branch'
        required: false
        default: 'main'
        type: string

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

**Utilisation** :
1. Aller dans **Actions** sur GitHub
2. Cliquer sur **"Run workflow"**
3. Saisir la branche Dockerfile (ex: `develop`, `feature/test`)
4. Cliquer sur **"Run workflow"**

---

### Cas 4 : Build Maven Seulement (Sans Docker)

**Contexte** : Projet Maven sans conteneurisation.

**Configuration** :

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

**Résultat** :
- Build Maven uniquement
- Publication vers GitHub Packages
- Pas de build Docker

---

### Cas 5 : Ignorer les Tests

**Contexte** : Build rapide sans exécuter les tests.

**Configuration** :

```yaml
jobs:
  build:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      java-version: '21'
      dockerfile-repo: 'tourem/docker-file-common'
      skip-tests: true
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

**Note** : Déconseillé pour les branches principales (`main`, `develop`).

---

## 🔍 Débogage

### Vérifier les Logs

1. Aller dans **Actions** sur GitHub
2. Sélectionner le workflow
3. Cliquer sur le job
4. Consulter les logs de chaque step

### Logs Importants

**Maven version** :
```
📦 Maven version: 1.0-SNAPSHOT
```

**Maven registry** :
```
📦 Maven registry: https://maven.pkg.github.com/tourem/my-project
```

**Docker registry** :
```
🐳 Docker registry: ghcr.io
```

**Module configuration** :
```
📦 Module: task-api
📦 Artifact: com.larbotech:task-api:jar
📦 Config: com.larbotech:task-api:zip:distribution
📦 Dockerfile repo: tourem/docker-file-common@main
📦 Version: 1.0-SNAPSHOT
```

**Artifact references** :
```
📦 Artifact reference: com.larbotech:task-api:jar:1.0-SNAPSHOT
📦 Config reference: com.larbotech:task-api:zip:distribution:1.0-SNAPSHOT
```

### Erreurs Courantes

#### Erreur : "Invalid JSON in docker-modules"

**Cause** : Format JSON invalide dans `docker-modules`

**Solution** : Vérifier la syntaxe JSON (virgules, guillemets, crochets)

**Exemple correct** :
```yaml
docker-modules: |
  [
    {
      "name": "my-app",
      "artifact": "com.example:my-app:jar",
      "config": "com.example:my-app:zip:conf"
    }
  ]
```

#### Erreur : "Dockerfile not found"

**Cause** : Repository ou branche Dockerfile incorrecte

**Solution** : Vérifier `dockerfile-repo` et `dockerfile-branch`

```yaml
dockerfile-repo: 'tourem/docker-file-common'  # Format: owner/repo
dockerfile-branch: 'main'                      # Branche existante
```

#### Erreur : "Artifact not found in GitHub Packages"

**Cause** : L'artifact Maven n'a pas été publié

**Solution** :
1. Vérifier que le job `build-and-publish` a réussi
2. Vérifier les permissions du `GITHUB_TOKEN`
3. Vérifier la configuration Maven dans le POM

---

## 📊 Workflow Complet

```
┌─────────────────────────────────────────────────────────────┐
│  Trigger (Push/PR/Manual)                                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Job 1: build-and-publish                                    │
│  ├─ Checkout code                                            │
│  ├─ Setup Java                                               │
│  ├─ Get Maven version                                        │
│  ├─ Build with Maven                                         │
│  ├─ Publish to GitHub Packages                               │
│  └─ Upload artifacts                                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Job 2: build-docker-images (Matrix)                         │
│  ├─ Checkout code                                            │
│  ├─ Checkout Dockerfile repo                                 │
│  ├─ Setup Docker Buildx                                      │
│  ├─ Login to Docker registry                                 │
│  ├─ Extract metadata (tags)                                  │
│  ├─ Build artifact references                                │
│  ├─ Build and push Docker image                              │
│  └─ Generate summary                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ Checklist de Migration

### Avant de Commencer

- [ ] Lire la documentation
- [ ] Identifier les modules de votre projet
- [ ] Vérifier que le Dockerfile est dans un repository partagé
- [ ] Vérifier les références Maven (groupId, artifactId)

### Configuration

- [ ] Créer `.github/workflows/ci.yml`
- [ ] Configurer `java-version`
- [ ] Configurer `dockerfile-repo` et `dockerfile-branch`
- [ ] Configurer `docker-modules` avec tous les modules
- [ ] Ajouter `secrets: inherit`

### Test

- [ ] Commit et push
- [ ] Vérifier que le workflow s'exécute
- [ ] Vérifier les logs
- [ ] Vérifier que les artifacts Maven sont publiés
- [ ] Vérifier que les images Docker sont publiées

### Validation

- [ ] Tester le déploiement avec les images Docker
- [ ] Vérifier les tags Docker
- [ ] Valider avec l'équipe

---

## 🎯 Bonnes Pratiques

1. **Toujours utiliser `secrets: inherit`** pour passer les secrets au workflow réutilisable
2. **Utiliser des versions spécifiques** pour `java-version` (ex: `'21'` au lieu de `'latest'`)
3. **Tester sur une branche** avant de merger sur `main`
4. **Documenter les modules** dans le README du projet
5. **Utiliser le déclenchement manuel** pour tester différentes branches de Dockerfile

---

## 📚 Ressources

- [README](./README.md) - Vue d'ensemble
- [Exemples](./examples/) - Exemples complets
- [Migration Strategy](../MIGRATION_STRATEGY.md) - Stratégie de migration Jenkins

---

**Version** : 1.0  
**Dernière mise à jour** : 2025-11-03


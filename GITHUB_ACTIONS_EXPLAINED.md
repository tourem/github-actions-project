# 📚 GitHub Actions - Explications Détaillées

Ce document explique les concepts et syntaxes utilisés dans le workflow `.github/workflows/ci.yml`.

## 📋 Table des Matières

1. [github.event.inputs.dockerfile_branch](#1-githubeventinputsdockerfile_branch)
2. [if: success()](#2-if-success)
3. [type=raw,value=latest,enable={{is_default_branch}}](#3-typerawvaluelatestenableis_default_branch)
4. [Autres Concepts Importants](#4-autres-concepts-importants)

---

## 1. `github.event.inputs.dockerfile_branch`

### 🔍 Qu'est-ce que c'est ?

`github.event.inputs.dockerfile_branch` est une **variable d'entrée** (input) pour les workflows déclenchés manuellement via `workflow_dispatch`.

### 📝 Définition dans le Workflow

Dans notre fichier `.github/workflows/ci.yml` :

```yaml
on:
  workflow_dispatch:
    inputs:
      dockerfile_branch:
        description: 'Branch of docker-file-common repository to use'
        required: false
        default: 'main'
        type: string
```

### 🎯 D'où vient cette valeur ?

La valeur provient de **l'interface GitHub Actions** lorsque vous déclenchez manuellement le workflow :

1. **Sur GitHub.com** :
   - Aller dans **Actions**
   - Sélectionner le workflow **"CI/CD Pipeline"**
   - Cliquer sur **"Run workflow"**
   - Un formulaire apparaît avec un champ : **"Branch of docker-file-common repository to use"**
   - Vous saisissez la valeur (ex: `develop`, `feature/test`, `v1.0.0`)
   - Cette valeur est stockée dans `github.event.inputs.dockerfile_branch`

### 📊 Schéma du Flux

```
┌─────────────────────────────────────────────────────────────┐
│  Interface GitHub Actions                                    │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Run workflow                                           │ │
│  │                                                        │ │
│  │ Branch of docker-file-common repository to use:       │ │
│  │ [develop                                          ]    │ │
│  │                                                        │ │
│  │ [Run workflow]                                         │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
        github.event.inputs.dockerfile_branch = "develop"
```

### 💡 Utilisation dans le Workflow

```yaml
env:
  DOCKERFILE_BRANCH: ${{ github.event.inputs.dockerfile_branch || 'main' }}
```

**Explication** :
- `${{ ... }}` : Syntaxe pour accéder aux variables GitHub Actions
- `github.event.inputs.dockerfile_branch` : Valeur saisie par l'utilisateur
- `|| 'main'` : Opérateur OR - si la valeur est vide/null, utilise `'main'` par défaut

### 📌 Exemples

| Déclenchement | Valeur Saisie | Résultat |
|---------------|---------------|----------|
| Push automatique | N/A (pas d'input) | `DOCKERFILE_BRANCH = 'main'` |
| Manuel (champ vide) | *(vide)* | `DOCKERFILE_BRANCH = 'main'` |
| Manuel | `develop` | `DOCKERFILE_BRANCH = 'develop'` |
| Manuel | `feature/test` | `DOCKERFILE_BRANCH = 'feature/test'` |
| Manuel | `v1.2.0` | `DOCKERFILE_BRANCH = 'v1.2.0'` |

### 🔗 Accès dans les Steps

```yaml
- name: Checkout Dockerfile repository
  uses: actions/checkout@v4
  with:
    repository: tourem/docker-file-common
    ref: ${{ env.DOCKERFILE_BRANCH }}  # Utilise la valeur
    path: docker-file-common
```

---

## 2. `if: success()`

### 🔍 Qu'est-ce que c'est ?

`if: success()` est une **condition d'exécution** qui vérifie si toutes les étapes précédentes ont réussi.

### 📝 Syntaxe

```yaml
- name: Mon étape
  if: success()
  run: echo "Cette étape s'exécute seulement si tout a réussi"
```

### 🎯 Fonctions de Statut Disponibles

| Fonction | Description | Quand s'exécute |
|----------|-------------|-----------------|
| `success()` | Toutes les étapes précédentes ont réussi | ✅ Tout est OK |
| `failure()` | Au moins une étape a échoué | ❌ Échec détecté |
| `always()` | Toujours exécuter | ✅❌ Dans tous les cas |
| `cancelled()` | Le workflow a été annulé | 🚫 Annulation |

### 💡 Exemples Pratiques

#### Exemple 1 : Notification de Succès

```yaml
- name: Build application
  run: mvn clean package

- name: Send success notification
  if: success()
  run: echo "✅ Build réussi !"
```

**Résultat** :
- Si `mvn clean package` réussit → notification envoyée
- Si `mvn clean package` échoue → notification **non** envoyée

#### Exemple 2 : Notification d'Échec

```yaml
- name: Build application
  run: mvn clean package

- name: Send failure notification
  if: failure()
  run: echo "❌ Build échoué !"
```

**Résultat** :
- Si `mvn clean package` réussit → notification **non** envoyée
- Si `mvn clean package` échoue → notification envoyée

#### Exemple 3 : Nettoyage Toujours Exécuté

```yaml
- name: Build application
  run: mvn clean package

- name: Cleanup
  if: always()
  run: rm -rf /tmp/build
```

**Résultat** :
- Nettoyage exécuté **dans tous les cas** (succès ou échec)

### 📊 Flux de Décision

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Build                                               │
│  run: mvn clean package                                      │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ├─────────────┬─────────────┐
                      │             │             │
                  ✅ Success    ❌ Failure    🚫 Cancelled
                      │             │             │
                      ▼             ▼             ▼
            ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
            │ if: success()│ │ if: failure()│ │if: cancelled│
            │   ✅ RUN    │ │   ✅ RUN    │ │   ✅ RUN    │
            └─────────────┘ └─────────────┘ └─────────────┘
                      │             │             │
                      └─────────────┴─────────────┘
                                    │
                                    ▼
                          ┌─────────────────┐
                          │  if: always()   │
                          │    ✅ RUN       │
                          └─────────────────┘
```

### 🔗 Dans Notre Workflow

```yaml
- name: Upload task-api JAR
  if: success()
  uses: actions/upload-artifact@v4
  with:
    name: task-api-jar
    path: task-api/target/*.jar
```

**Explication** :
- L'upload ne se fait **que si** les étapes précédentes (build, tests) ont réussi
- Si le build échoue, pas besoin d'uploader un JAR corrompu

---

## 3. `type=raw,value=latest,enable={{is_default_branch}}`

### 🔍 Qu'est-ce que c'est ?

C'est une **règle de tagging** pour les images Docker utilisée par l'action `docker/metadata-action`.

### 📝 Contexte dans le Workflow

```yaml
- name: Extract metadata for Docker
  id: meta
  uses: docker/metadata-action@v5
  with:
    images: ghcr.io/${{ github.repository }}/${{ matrix.module.name }}
    tags: |
      type=ref,event=branch
      type=sha,prefix={{branch}}-
      type=raw,value=latest,enable={{is_default_branch}}
      type=raw,value=${{ needs.build-and-publish.outputs.version }}
```

### 🎯 Décomposition de la Règle

```
type=raw,value=latest,enable={{is_default_branch}}
│    │   │     │      │      │
│    │   │     │      │      └─ Condition d'activation
│    │   │     │      └──────── Paramètre enable
│    │   │     └─────────────── Valeur du tag
│    │   └───────────────────── Paramètre value
│    └───────────────────────── Type de règle (raw = valeur brute)
└────────────────────────────── Paramètre type
```

### 📊 Explication Détaillée

| Élément | Valeur | Signification |
|---------|--------|---------------|
| `type` | `raw` | Type de tag : valeur brute (non calculée) |
| `value` | `latest` | Le tag sera `latest` |
| `enable` | `{{is_default_branch}}` | Actif **seulement** si on est sur la branche par défaut |

### 💡 Qu'est-ce que `{{is_default_branch}}` ?

`{{is_default_branch}}` est une **variable de template** fournie par `docker/metadata-action` :

- ✅ `true` si la branche actuelle est la branche par défaut du repository (généralement `main`)
- ❌ `false` sinon

### 📌 Exemples de Tagging

#### Scénario 1 : Push sur `main` (branche par défaut)

```yaml
tags: |
  type=ref,event=branch
  type=sha,prefix={{branch}}-
  type=raw,value=latest,enable={{is_default_branch}}
  type=raw,value=1.0-SNAPSHOT
```

**Résultat** :
```
ghcr.io/tourem/github-actions-project/task-api:main
ghcr.io/tourem/github-actions-project/task-api:main-abc123d
ghcr.io/tourem/github-actions-project/task-api:latest        ← Ajouté car is_default_branch = true
ghcr.io/tourem/github-actions-project/task-api:1.0-SNAPSHOT
```

#### Scénario 2 : Push sur `develop` (branche non-défaut)

```yaml
tags: |
  type=ref,event=branch
  type=sha,prefix={{branch}}-
  type=raw,value=latest,enable={{is_default_branch}}
  type=raw,value=1.0-SNAPSHOT
```

**Résultat** :
```
ghcr.io/tourem/github-actions-project/task-api:develop
ghcr.io/tourem/github-actions-project/task-api:develop-xyz789e
                                                              ← PAS de tag latest car is_default_branch = false
ghcr.io/tourem/github-actions-project/task-api:1.0-SNAPSHOT
```

### 🎯 Pourquoi cette Règle ?

**Objectif** : Le tag `latest` doit **toujours** pointer vers la version de production (branche `main`).

**Avantages** :
1. ✅ **Clarté** : `latest` = version stable de production
2. ✅ **Sécurité** : Évite que `develop` ou une feature écrase `latest`
3. ✅ **Convention** : Suit les bonnes pratiques Docker

### 📊 Tableau Récapitulatif des Types de Tags

| Type | Description | Exemple | Quand |
|------|-------------|---------|-------|
| `type=ref,event=branch` | Nom de la branche | `main`, `develop` | Toujours |
| `type=sha,prefix={{branch}}-` | SHA du commit | `main-abc123d` | Toujours |
| `type=raw,value=latest,enable={{is_default_branch}}` | Tag `latest` | `latest` | Seulement sur `main` |
| `type=raw,value=X.Y.Z` | Version spécifique | `1.0-SNAPSHOT` | Toujours |

---

## 4. Autres Concepts Importants

### 4.1. `needs`

```yaml
build-docker-images:
  needs: build-and-publish
```

**Signification** : Le job `build-docker-images` attend que le job `build-and-publish` soit terminé avec succès.

**Flux** :
```
build-and-publish (Job 1)
        ↓
    ✅ Success
        ↓
build-docker-images (Job 2)
```

### 4.2. `matrix`

```yaml
strategy:
  matrix:
    module:
      - name: task-api
        port: 8080
      - name: task-batch
        port: 8081
```

**Signification** : Exécute le job **2 fois** en parallèle, une fois pour chaque module.

**Résultat** :
```
Job 1: matrix.module.name = "task-api", matrix.module.port = 8080
Job 2: matrix.module.name = "task-batch", matrix.module.port = 8081
```

### 4.3. `outputs`

```yaml
jobs:
  build-and-publish:
    outputs:
      version: ${{ steps.get-version.outputs.version }}
    
    steps:
      - name: Get Maven version
        id: get-version
        run: |
          VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
          echo "version=$VERSION" >> $GITHUB_OUTPUT
```

**Signification** : Partage la version entre jobs.

**Utilisation** :
```yaml
build-docker-images:
  needs: build-and-publish
  steps:
    - name: Use version
      run: echo "Version: ${{ needs.build-and-publish.outputs.version }}"
```

### 4.4. `secrets.GITHUB_TOKEN`

```yaml
password: ${{ secrets.GITHUB_TOKEN }}
```

**Signification** : Token d'authentification automatique fourni par GitHub Actions.

**Caractéristiques** :
- ✅ Créé automatiquement pour chaque workflow
- ✅ Permissions limitées au repository
- ✅ Expire à la fin du workflow
- ✅ Pas besoin de le créer manuellement

### 4.5. `github.repository_owner`

```yaml
GITHUB_USER=${{ github.repository_owner }}
```

**Signification** : Nom du propriétaire du repository.

**Exemple** :
- Repository : `tourem/github-actions-project`
- `github.repository_owner` = `tourem`

### 4.6. `github.ref`

```yaml
if: github.ref == 'refs/heads/main'
```

**Signification** : Référence Git complète de la branche/tag.

**Exemples** :
- Branche `main` : `refs/heads/main`
- Branche `develop` : `refs/heads/develop`
- Tag `v1.0.0` : `refs/tags/v1.0.0`

---

## 📚 Résumé des Concepts

| Concept | Description | Exemple |
|---------|-------------|---------|
| `github.event.inputs.X` | Input manuel du workflow | `github.event.inputs.dockerfile_branch` |
| `if: success()` | Condition d'exécution | `if: success()`, `if: failure()` |
| `type=raw,value=latest,enable={{is_default_branch}}` | Règle de tagging Docker | Tag `latest` seulement sur `main` |
| `needs` | Dépendance entre jobs | `needs: build-and-publish` |
| `matrix` | Exécution parallèle | `matrix.module.name` |
| `outputs` | Partage de données entre jobs | `outputs.version` |
| `secrets.GITHUB_TOKEN` | Token d'authentification | Fourni automatiquement |

---

## 🎯 Exemples Pratiques Complets

### Exemple 1 : Workflow avec Input Manuel

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: |
          echo "Deploying to: ${{ github.event.inputs.environment }}"
```

### Exemple 2 : Conditions Multiples

```yaml
- name: Deploy to production
  if: success() && github.ref == 'refs/heads/main'
  run: ./deploy.sh production

- name: Deploy to staging
  if: success() && github.ref == 'refs/heads/develop'
  run: ./deploy.sh staging

- name: Cleanup on failure
  if: failure()
  run: ./cleanup.sh
```

### Exemple 3 : Tags Docker Avancés

```yaml
- name: Docker meta
  id: meta
  uses: docker/metadata-action@v5
  with:
    images: ghcr.io/myorg/myapp
    tags: |
      # Tag avec le nom de la branche
      type=ref,event=branch
      
      # Tag avec le SHA du commit
      type=sha,prefix={{branch}}-
      
      # Tag 'latest' seulement sur main
      type=raw,value=latest,enable={{is_default_branch}}
      
      # Tag avec la version
      type=semver,pattern={{version}}
      
      # Tag avec major.minor
      type=semver,pattern={{major}}.{{minor}}
```

---

**Date** : 2025-11-03  
**Version** : 1.0  
**Auteur** : Documentation GitHub Actions


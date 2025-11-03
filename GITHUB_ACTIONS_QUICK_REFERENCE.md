# 🚀 GitHub Actions - Référence Rapide

Guide de référence rapide pour les concepts GitHub Actions utilisés dans notre workflow.

---

## 📌 Variables et Contextes

### `github.event.inputs.*`

**Utilisation** : Récupérer les inputs d'un workflow manuel

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment'
        default: 'staging'

jobs:
  deploy:
    steps:
      - run: echo "${{ github.event.inputs.environment }}"
```

**Valeur** : Saisie par l'utilisateur dans l'interface GitHub Actions

---

### `github.repository_owner`

**Utilisation** : Nom du propriétaire du repository

```yaml
- run: echo "${{ github.repository_owner }}"
# Output: tourem
```

---

### `github.repository`

**Utilisation** : Nom complet du repository

```yaml
- run: echo "${{ github.repository }}"
# Output: tourem/github-actions-project
```

---

### `github.ref`

**Utilisation** : Référence Git complète

```yaml
- run: echo "${{ github.ref }}"
# Output: refs/heads/main
```

**Exemples** :
- Branche : `refs/heads/main`
- Tag : `refs/tags/v1.0.0`
- PR : `refs/pull/123/merge`

---

### `github.sha`

**Utilisation** : SHA du commit

```yaml
- run: echo "${{ github.sha }}"
# Output: abc123def456...
```

---

### `secrets.GITHUB_TOKEN`

**Utilisation** : Token d'authentification automatique

```yaml
- uses: docker/login-action@v3
  with:
    password: ${{ secrets.GITHUB_TOKEN }}
```

**Caractéristiques** :
- ✅ Créé automatiquement
- ✅ Expire à la fin du workflow
- ✅ Permissions limitées au repository

---

## 🔀 Conditions d'Exécution

### `if: success()`

**Utilisation** : Exécuter seulement si tout a réussi

```yaml
- name: Deploy
  if: success()
  run: ./deploy.sh
```

---

### `if: failure()`

**Utilisation** : Exécuter seulement en cas d'échec

```yaml
- name: Notify failure
  if: failure()
  run: ./notify-error.sh
```

---

### `if: always()`

**Utilisation** : Toujours exécuter

```yaml
- name: Cleanup
  if: always()
  run: rm -rf /tmp/*
```

---

### `if: cancelled()`

**Utilisation** : Exécuter si le workflow est annulé

```yaml
- name: Rollback
  if: cancelled()
  run: ./rollback.sh
```

---

### Conditions Combinées

```yaml
# ET logique
- if: success() && github.ref == 'refs/heads/main'

# OU logique
- if: failure() || cancelled()

# Négation
- if: "!cancelled()"
```

---

## 🏗️ Structure des Jobs

### `needs`

**Utilisation** : Dépendance entre jobs

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building..."

  deploy:
    needs: build  # Attend que 'build' soit terminé
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying..."
```

**Flux** :
```
build → deploy
```

---

### `outputs`

**Utilisation** : Partager des données entre jobs

```yaml
jobs:
  build:
    outputs:
      version: ${{ steps.get-version.outputs.version }}
    steps:
      - id: get-version
        run: echo "version=1.0.0" >> $GITHUB_OUTPUT

  deploy:
    needs: build
    steps:
      - run: echo "Version: ${{ needs.build.outputs.version }}"
```

---

### `strategy.matrix`

**Utilisation** : Exécution parallèle avec différentes configurations

```yaml
strategy:
  matrix:
    module:
      - name: task-api
        port: 8080
      - name: task-batch
        port: 8081

steps:
  - run: echo "Module: ${{ matrix.module.name }}"
  - run: echo "Port: ${{ matrix.module.port }}"
```

**Résultat** : 2 jobs en parallèle

---

## 🐳 Docker Metadata Action

### Tags de Base

```yaml
- uses: docker/metadata-action@v5
  with:
    images: ghcr.io/myorg/myapp
    tags: |
      type=ref,event=branch
      type=sha
      type=raw,value=latest
```

---

### `type=ref,event=branch`

**Utilisation** : Tag avec le nom de la branche

**Exemples** :
- Branche `main` → Tag `main`
- Branche `develop` → Tag `develop`

---

### `type=sha`

**Utilisation** : Tag avec le SHA du commit

**Exemple** :
- Commit `abc123d...` → Tag `sha-abc123d`

---

### `type=sha,prefix={{branch}}-`

**Utilisation** : Tag avec branche + SHA

**Exemple** :
- Branche `main`, commit `abc123d` → Tag `main-abc123d`

---

### `type=raw,value=latest`

**Utilisation** : Tag fixe

**Exemple** :
- Tag `latest` (toujours)

---

### `type=raw,value=latest,enable={{is_default_branch}}`

**Utilisation** : Tag conditionnel

**Exemples** :
- Branche `main` (défaut) → Tag `latest` ✅
- Branche `develop` → Pas de tag `latest` ❌

---

### `type=semver,pattern={{version}}`

**Utilisation** : Tag avec version sémantique

**Exemples** :
- Tag Git `v1.2.3` → Tag Docker `1.2.3`

---

### Variables de Template

| Variable | Description | Exemple |
|----------|-------------|---------|
| `{{branch}}` | Nom de la branche | `main` |
| `{{sha}}` | SHA court du commit | `abc123d` |
| `{{is_default_branch}}` | Branche par défaut ? | `true`/`false` |
| `{{version}}` | Version du tag | `1.2.3` |
| `{{major}}` | Version majeure | `1` |
| `{{minor}}` | Version mineure | `2` |

---

## 📦 Actions Courantes

### Checkout

```yaml
- uses: actions/checkout@v4
```

**Options** :
```yaml
- uses: actions/checkout@v4
  with:
    repository: owner/repo  # Repository différent
    ref: develop            # Branche/tag spécifique
    path: my-dir            # Répertoire de destination
```

---

### Upload Artifact

```yaml
- uses: actions/upload-artifact@v4
  with:
    name: my-artifact
    path: target/*.jar
```

---

### Download Artifact

```yaml
- uses: actions/download-artifact@v4
  with:
    name: my-artifact
    path: ./artifacts
```

---

### Docker Login

```yaml
- uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

---

### Docker Build and Push

```yaml
- uses: docker/build-push-action@v5
  with:
    context: .
    file: ./Dockerfile
    push: true
    tags: myapp:latest
    build-args: |
      VERSION=1.0.0
      ENV=production
```

---

## 🔧 Opérateurs et Fonctions

### Opérateur OR (`||`)

```yaml
env:
  BRANCH: ${{ github.event.inputs.branch || 'main' }}
```

**Signification** : Si `github.event.inputs.branch` est vide, utilise `'main'`

---

### Opérateur AND (`&&`)

```yaml
if: success() && github.ref == 'refs/heads/main'
```

**Signification** : Les deux conditions doivent être vraies

---

### Comparaison

```yaml
if: github.ref == 'refs/heads/main'      # Égalité
if: github.ref != 'refs/heads/develop'   # Différence
```

---

### Fonctions de Chaîne

```yaml
if: startsWith(github.ref, 'refs/tags/')
if: endsWith(github.ref, '/main')
if: contains(github.ref, 'feature')
```

---

## 📊 Exemples Complets

### Workflow avec Input Manuel

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment'
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
      - run: echo "Deploying to ${{ github.event.inputs.environment }}"
```

---

### Workflow avec Matrix

```yaml
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node: [14, 16, 18]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node }}
      - run: npm test
```

---

### Workflow avec Conditions

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm run build

      - name: Deploy to production
        if: success() && github.ref == 'refs/heads/main'
        run: npm run deploy:prod

      - name: Deploy to staging
        if: success() && github.ref == 'refs/heads/develop'
        run: npm run deploy:staging

      - name: Notify on failure
        if: failure()
        run: ./notify-slack.sh
```

---

### Workflow avec Outputs

```yaml
jobs:
  build:
    outputs:
      version: ${{ steps.version.outputs.value }}
      artifact: ${{ steps.build.outputs.filename }}
    steps:
      - id: version
        run: echo "value=1.0.0" >> $GITHUB_OUTPUT
      
      - id: build
        run: |
          echo "filename=app-1.0.0.jar" >> $GITHUB_OUTPUT

  deploy:
    needs: build
    steps:
      - run: |
          echo "Version: ${{ needs.build.outputs.version }}"
          echo "Artifact: ${{ needs.build.outputs.artifact }}"
```

---

## 🎯 Bonnes Pratiques

### 1. Toujours Utiliser des Versions Spécifiques

✅ **Bon** :
```yaml
- uses: actions/checkout@v4
```

❌ **Mauvais** :
```yaml
- uses: actions/checkout@main
```

---

### 2. Utiliser `if: success()` pour les Étapes Critiques

```yaml
- name: Upload artifact
  if: success()
  uses: actions/upload-artifact@v4
```

---

### 3. Toujours Nettoyer avec `if: always()`

```yaml
- name: Cleanup
  if: always()
  run: rm -rf /tmp/build
```

---

### 4. Utiliser `needs` pour les Dépendances

```yaml
jobs:
  build:
    # ...
  
  test:
    needs: build
    # ...
  
  deploy:
    needs: [build, test]
    # ...
```

---

### 5. Protéger les Secrets

✅ **Bon** :
```yaml
- run: echo "Token: ***"
  env:
    TOKEN: ${{ secrets.MY_TOKEN }}
```

❌ **Mauvais** :
```yaml
- run: echo "Token: ${{ secrets.MY_TOKEN }}"
```

---

## 📚 Ressources

- [Documentation GitHub Actions](https://docs.github.com/en/actions)
- [Marketplace GitHub Actions](https://github.com/marketplace?type=actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

---

**Date** : 2025-11-03  
**Version** : 1.0


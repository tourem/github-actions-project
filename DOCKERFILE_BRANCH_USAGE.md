# 🔀 Utilisation de Branches Différentes pour le Dockerfile

## ✅ Fonctionnalité Ajoutée

Le workflow GitHub Actions permet maintenant de spécifier quelle branche du repository `docker-file-common` utiliser pour le Dockerfile.

## 📝 Configuration

### 1. **Input `workflow_dispatch`**

Un nouvel input a été ajouté pour permettre la sélection de la branche :

```yaml
workflow_dispatch:
  inputs:
    dockerfile_branch:
      description: 'Branch of docker-file-common repository to use'
      required: false
      default: 'main'
      type: string
```

### 2. **Variable d'Environnement**

La branche est stockée dans une variable d'environnement au niveau du job :

```yaml
env:
  DOCKERFILE_BRANCH: ${{ github.event.inputs.dockerfile_branch || 'main' }}
```

**Logique** :
- Si le workflow est déclenché manuellement → utilise la branche spécifiée
- Sinon → utilise `main` par défaut

### 3. **Checkout avec la Branche Spécifiée**

```yaml
- name: Checkout Dockerfile repository
  uses: actions/checkout@v4
  with:
    repository: tourem/docker-file-common
    ref: ${{ env.DOCKERFILE_BRANCH }}
    path: docker-file-common
```

## 🚀 Utilisation

### Cas 1 : Déclenchement Automatique (Push/PR)

Lors d'un push sur `main` ou `develop`, le workflow utilise automatiquement la branche `main` du repository `docker-file-common`.

```bash
git push origin main
# → Utilise docker-file-common@main
```

### Cas 2 : Déclenchement Manuel avec Branche par Défaut

1. Aller sur GitHub → Actions
2. Sélectionner le workflow "CI/CD Pipeline"
3. Cliquer sur "Run workflow"
4. Laisser le champ vide ou saisir `main`
5. Cliquer sur "Run workflow"

**Résultat** : Utilise `docker-file-common@main`

### Cas 3 : Déclenchement Manuel avec Branche Spécifique

1. Aller sur GitHub → Actions
2. Sélectionner le workflow "CI/CD Pipeline"
3. Cliquer sur "Run workflow"
4. Dans le champ "Branch of docker-file-common repository to use", saisir : `develop`
5. Cliquer sur "Run workflow"

**Résultat** : Utilise `docker-file-common@develop`

### Cas 4 : Tester une Branche Feature

Pour tester une nouvelle version du Dockerfile depuis une branche feature :

1. Créer une branche dans `docker-file-common` :
   ```bash
   cd /tmp/docker-file-common
   git checkout -b feature/new-optimization
   # Modifier le Dockerfile
   git commit -am "feat: optimize Docker layers"
   git push origin feature/new-optimization
   ```

2. Déclencher le workflow manuellement :
   - Aller sur GitHub → Actions
   - Sélectionner "CI/CD Pipeline"
   - Cliquer sur "Run workflow"
   - Saisir : `feature/new-optimization`
   - Cliquer sur "Run workflow"

**Résultat** : Utilise `docker-file-common@feature/new-optimization`

## 📊 Exemples de Branches

| Branche | Usage | Exemple |
|---------|-------|---------|
| `main` | Production, version stable | Déploiement en production |
| `develop` | Développement, nouvelles features | Tests d'intégration |
| `feature/xxx` | Feature spécifique | Test d'une nouvelle optimisation |
| `hotfix/xxx` | Correction urgente | Fix d'un bug critique |
| `v1.0.0` | Version taguée | Utiliser une version spécifique |

## 🔍 Vérification de la Branche Utilisée

Le workflow affiche la branche utilisée dans les logs :

```yaml
- name: Display Dockerfile branch
  run: |
    echo "📦 Using Dockerfile from branch: ${{ env.DOCKERFILE_BRANCH }}"
    echo "📁 Dockerfile path: ./docker-file-common/Dockerfile"
```

**Logs GitHub Actions** :
```
📦 Using Dockerfile from branch: develop
📁 Dockerfile path: ./docker-file-common/Dockerfile
```

## 🎯 Cas d'Usage Pratiques

### 1. **Test d'une Nouvelle Version du Dockerfile**

Vous voulez tester une optimisation du Dockerfile sans impacter la production :

```bash
# Dans docker-file-common
git checkout -b feature/alpine-optimization
# Modifier le Dockerfile
git push origin feature/alpine-optimization

# Déclencher le workflow avec cette branche
# → Teste la nouvelle version sans toucher à main
```

### 2. **Rollback Rapide**

Si une nouvelle version du Dockerfile cause des problèmes :

```bash
# Déclencher le workflow manuellement avec une version antérieure
# Branch: v1.0.0 (tag précédent)
# → Revient à une version stable
```

### 3. **Environnements Différents**

Utiliser des Dockerfiles différents selon l'environnement :

- `main` → Production
- `develop` → Staging/Dev
- `feature/xxx` → Tests

### 4. **A/B Testing**

Comparer deux versions du Dockerfile :

```bash
# Build 1 avec main
# Build 2 avec feature/new-base-image
# Comparer les performances
```

## 🔧 Configuration Avancée

### Utiliser un Tag Spécifique

Vous pouvez aussi utiliser un tag Git :

```
Branch: v1.2.0
```

### Utiliser un Commit SHA

Pour une version très spécifique :

```
Branch: abc123def456
```

## 📝 Workflow Complet

```
┌─────────────────────────────────────────────────────────────┐
│  Déclenchement du Workflow                                   │
│  ├─ Push/PR → DOCKERFILE_BRANCH = 'main'                    │
│  └─ Manual → DOCKERFILE_BRANCH = input ou 'main'            │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Checkout docker-file-common                                 │
│  └─ ref: ${{ env.DOCKERFILE_BRANCH }}                       │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Display Branch                                              │
│  └─ Echo: "Using Dockerfile from branch: XXX"               │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Build Docker Image                                          │
│  └─ file: ./docker-file-common/Dockerfile                   │
└─────────────────────────────────────────────────────────────┘
```

## ✅ Avantages

1. ✅ **Flexibilité** : Tester différentes versions du Dockerfile
2. ✅ **Sécurité** : Tester avant de merger dans main
3. ✅ **Rollback** : Revenir à une version antérieure facilement
4. ✅ **Environnements** : Dockerfiles différents par environnement
5. ✅ **A/B Testing** : Comparer les performances
6. ✅ **Versioning** : Utiliser des tags pour les versions stables

## 🎯 Bonnes Pratiques

1. **Toujours tester sur une branche feature** avant de merger dans main
2. **Utiliser des tags** pour les versions stables (v1.0.0, v1.1.0, etc.)
3. **Documenter les changements** dans le repository docker-file-common
4. **Vérifier les logs** pour confirmer la branche utilisée
5. **Faire des tests** avant de déployer en production

## 📚 Ressources

- Repository Dockerfile : https://github.com/tourem/docker-file-common
- Documentation Migration : `DOCKER_MIGRATION.md`
- Script de Migration : `migrate-dockerfile.sh`

---

**Date** : 2025-11-03  
**Version** : 1.0  
**Status** : ✅ Fonctionnalité active


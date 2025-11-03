# 🐳 Modifications Docker - Format APP_LOCATION et CONF_LOCATION

## ✅ Modifications Effectuées

Le Dockerfile a été modifié pour utiliser le même format que `Dockerfile.alpine` avec les variables `APP_LOCATION` et `CONF_LOCATION`.

## 📝 Changements Principaux

### 1. **Format des Arguments**

**Avant** :
```dockerfile
ARG GITHUB_REPO
ARG MODULE_NAME
ARG MODULE_VERSION=1.0-SNAPSHOT
```

**Après** :
```dockerfile
ARG APP_LOCATION=com.larbotech:task-api:1.0-SNAPSHOT
ARG CONF_LOCATION=com.larbotech:task-api:1.0-SNAPSHOT
```

### 2. **Parsing des Variables**

Le Dockerfile parse maintenant les variables au format `groupId:artifactId:version` :

```dockerfile
# Pour APP_LOCATION (JAR)
GROUP_ID=$(echo "${APP_LOCATION}" | cut -d':' -f1)
ARTIFACT_ID=$(echo "${APP_LOCATION}" | cut -d':' -f2)
VERSION=$(echo "${APP_LOCATION}" | cut -d':' -f3)
```

```dockerfile
# Pour CONF_LOCATION (ZIP)
GROUP_ID=$(echo "${CONF_LOCATION}" | cut -d':' -f1)
ARTIFACT_ID=$(echo "${CONF_LOCATION}" | cut -d':' -f2)
VERSION=$(echo "${CONF_LOCATION}" | cut -d':' -f3)
```

### 3. **Construction des URLs**

Les URLs sont construites dynamiquement à partir des variables parsées :

**Pour le JAR** :
```
https://maven.pkg.github.com/{GITHUB_USER}/github-actions-project/{GROUP_PATH}/{ARTIFACT_ID}/{VERSION}/{ARTIFACT_ID}-{VERSION}.jar
```

**Pour le ZIP** :
```
https://maven.pkg.github.com/{GITHUB_USER}/github-actions-project/{GROUP_PATH}/{ARTIFACT_ID}/{VERSION}/{ARTIFACT_ID}-{VERSION}-distribution.zip
```

## 🔧 Arguments de Build

| Argument | Description | Format | Exemple |
|----------|-------------|--------|---------|
| `GITHUB_USER` | Nom d'utilisateur GitHub | string | `tourem` |
| `GITHUB_TOKEN` | Token d'authentification | string | `ghp_xxxxx` |
| `APP_LOCATION` | Localisation du JAR | `groupId:artifactId:version` | `com.larbotech:task-api:1.0-SNAPSHOT` |
| `CONF_LOCATION` | Localisation du ZIP | `groupId:artifactId:version` | `com.larbotech:task-api:1.0-SNAPSHOT` |

## 🚀 Utilisation

### Build Local - task-api

```bash
docker build \
  --build-arg GITHUB_USER=tourem \
  --build-arg GITHUB_TOKEN=$GITHUB_TOKEN \
  --build-arg APP_LOCATION=com.larbotech:task-api:1.0-SNAPSHOT \
  --build-arg CONF_LOCATION=com.larbotech:task-api:1.0-SNAPSHOT \
  -t task-api:local \
  -f Dockerfile .
```

### Build Local - task-batch

```bash
docker build \
  --build-arg GITHUB_USER=tourem \
  --build-arg GITHUB_TOKEN=$GITHUB_TOKEN \
  --build-arg APP_LOCATION=com.larbotech:task-batch:1.0-SNAPSHOT \
  --build-arg CONF_LOCATION=com.larbotech:task-batch:1.0-SNAPSHOT \
  -t task-batch:local \
  -f Dockerfile .
```

## 🔄 GitHub Actions Workflow

Le workflow a été mis à jour pour utiliser le nouveau format :

```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    context: .
    file: ./Dockerfile
    push: true
    tags: ${{ steps.meta.outputs.tags }}
    labels: ${{ steps.meta.outputs.labels }}
    build-args: |
      GITHUB_USER=${{ github.repository_owner }}
      GITHUB_TOKEN=${{ secrets.GITHUB_TOKEN }}
      APP_LOCATION=com.larbotech:${{ matrix.module.name }}:${{ needs.build-and-publish.outputs.version }}
      CONF_LOCATION=com.larbotech:${{ matrix.module.name }}:${{ needs.build-and-publish.outputs.version }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

## 📊 Exemple de Build

### Pour task-api:1.0-SNAPSHOT

**Arguments** :
- `APP_LOCATION=com.larbotech:task-api:1.0-SNAPSHOT`
- `CONF_LOCATION=com.larbotech:task-api:1.0-SNAPSHOT`

**URLs générées** :
- JAR: `https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-api/1.0-SNAPSHOT/task-api-1.0-SNAPSHOT.jar`
- ZIP: `https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-api/1.0-SNAPSHOT/task-api-1.0-SNAPSHOT-distribution.zip`

### Pour task-batch:1.0-SNAPSHOT

**Arguments** :
- `APP_LOCATION=com.larbotech:task-batch:1.0-SNAPSHOT`
- `CONF_LOCATION=com.larbotech:task-batch:1.0-SNAPSHOT`

**URLs générées** :
- JAR: `https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-batch/1.0-SNAPSHOT/task-batch-1.0-SNAPSHOT.jar`
- ZIP: `https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-batch/1.0-SNAPSHOT/task-batch-1.0-SNAPSHOT-distribution.zip`

## ✅ Avantages du Format

1. **Cohérence** : Même format que `Dockerfile.alpine`
2. **Flexibilité** : Facile de changer le groupId, artifactId ou version
3. **Clarté** : Format Maven standard `groupId:artifactId:version`
4. **Réutilisabilité** : Un seul Dockerfile pour tous les modules
5. **Maintenabilité** : Moins d'arguments à gérer

## 📝 Fichiers Modifiés

```
✅ Dockerfile                         - Format APP_LOCATION et CONF_LOCATION
✅ .github/workflows/ci.yml           - Build args mis à jour
✅ DOCKER.md                          - Documentation mise à jour
✅ DOCKER_SETUP_SUMMARY.md            - Résumé mis à jour
✅ DOCKER_CHANGES.md                  - Ce fichier
```

## 🎯 Comparaison avec Dockerfile.alpine

### Similitudes

- ✅ Format `APP_LOCATION` et `CONF_LOCATION`
- ✅ Parsing avec `cut -d':' -f1/2/3`
- ✅ Construction dynamique des URLs
- ✅ Multi-stage build
- ✅ Alpine Linux
- ✅ Utilisateur non-root

### Différences

| Aspect | Dockerfile.alpine | Dockerfile (ce projet) |
|--------|-------------------|------------------------|
| **Repository** | Paramétrable via URL | Fixe: `github-actions-project` |
| **Entrypoint** | Script externe `entrypoint.sh` | Commande inline |
| **Config location** | `/home/java/config` | `/app/config` |
| **Healthcheck** | Port 8080 fixe | Port 8080 (adaptable) |

## 🔍 Détails Techniques

### Parsing du Format groupId:artifactId:version

```bash
# Exemple: com.larbotech:task-api:1.0-SNAPSHOT
GROUP_ID=$(echo "${APP_LOCATION}" | cut -d':' -f1)      # com.larbotech
ARTIFACT_ID=$(echo "${APP_LOCATION}" | cut -d':' -f2)   # task-api
VERSION=$(echo "${APP_LOCATION}" | cut -d':' -f3)       # 1.0-SNAPSHOT
```

### Conversion du groupId en path

```bash
# com.larbotech → com/larbotech
GROUP_PATH=$(echo "${GROUP_ID}" | tr '.' '/')
```

### Construction du filename

```bash
# JAR
FILENAME="${ARTIFACT_ID}-${VERSION}.jar"
# Résultat: task-api-1.0-SNAPSHOT.jar

# ZIP
FILENAME="${ARTIFACT_ID}-${VERSION}-distribution.zip"
# Résultat: task-api-1.0-SNAPSHOT-distribution.zip
```

## 🎉 Résumé

Le Dockerfile utilise maintenant le même format que `Dockerfile.alpine` avec :

✅ **2 variables principales** : `APP_LOCATION` et `CONF_LOCATION`
✅ **Format Maven standard** : `groupId:artifactId:version`
✅ **Parsing automatique** : Extraction des composants
✅ **URLs dynamiques** : Construction automatique
✅ **Compatible GitHub Actions** : Intégration transparente

---

**Date** : 2025-11-03  
**Version** : 2.0  
**Status** : ✅ Prêt pour le déploiement


# 📦 Guide des Descripteurs de Déploiement

## 🎯 Objectif

Les descripteurs de déploiement sont des fichiers JSON générés automatiquement à chaque build CI/CD. Ils contiennent toutes les informations nécessaires pour déployer un module dans un environnement donné.

---

## 📁 Emplacement des Fichiers

Les descripteurs sont stockés dans le répertoire `deploy` de chaque module :

```
task-api/
└── deploy/
    └── deployment-descriptor-task-api.json

task-batch/
└── deploy/
    └── deployment-descriptor-task-batch.json
```

---

## 📋 Structure du Fichier JSON

### 1. Section `module`

Informations de base sur le module :

```json
{
  "module": {
    "name": "task-api",
    "version": "1.0-SNAPSHOT",
    "groupId": "com.larbotech",
    "artifactId": "task-api"
  }
}
```

### 2. Section `springProfiles`

Profils Spring Boot détectés automatiquement à partir des fichiers `application-{profile}.yml` :

```json
{
  "springProfiles": {
    "dev": "dev",
    "hml": "hml",
    "prd": "prd"
  }
}
```

**Détection automatique** :
- `application-dev.yml` → profil `dev`
- `application-hml.yml` → profil `hml`
- `application-prod.yml` → profil `prd`

### 3. Section `artifacts`

Artifacts Maven générés (JAR et distribution complète) :

```json
{
  "artifacts": {
    "jar": {
      "groupId": "com.larbotech",
      "artifactId": "task-api",
      "version": "1.0-SNAPSHOT",
      "type": "jar",
      "url": "https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-api/1.0-SNAPSHOT/task-api-1.0-SNAPSHOT.jar"
    },
    "distribution": {
      "groupId": "com.larbotech",
      "artifactId": "task-api",
      "version": "1.0-SNAPSHOT",
      "type": "zip",
      "classifier": "distribution",
      "url": "https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-api/1.0-SNAPSHOT/task-api-1.0-SNAPSHOT-distribution.zip"
    }
  }
}
```

### 4. Section `configurations`

Fichiers de configuration Vault par environnement :

```json
{
  "configurations": {
    "dev": {
      "groupId": "com.larbotech",
      "artifactId": "task-api",
      "version": "1.0-SNAPSHOT",
      "type": "zip",
      "classifier": "conf-dev",
      "url": "https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-api/1.0-SNAPSHOT/task-api-1.0-SNAPSHOT-conf-dev.zip",
      "vaultFile": "vault-dev.yml"
    },
    "hml": {
      "groupId": "com.larbotech",
      "artifactId": "task-api",
      "version": "1.0-SNAPSHOT",
      "type": "zip",
      "classifier": "conf-hml",
      "url": "https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-api/1.0-SNAPSHOT/task-api-1.0-SNAPSHOT-conf-hml.zip",
      "vaultFile": "vault-hml.yml"
    },
    "prd": {
      "groupId": "com.larbotech",
      "artifactId": "task-api",
      "version": "1.0-SNAPSHOT",
      "type": "zip",
      "classifier": "conf-prd",
      "url": "https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-api/1.0-SNAPSHOT/task-api-1.0-SNAPSHOT-conf-prd.zip",
      "vaultFile": "vault-prd.yml"
    }
  }
}
```

### 5. Section `docker`

Informations sur l'image Docker générée :

```json
{
  "docker": {
    "registry": "ghcr.io",
    "repository": "tourem/github-actions-project",
    "image": "ghcr.io/tourem/github-actions-project/task-api",
    "tags": {
      "version": "1.0-SNAPSHOT",
      "latest": "ghcr.io/tourem/github-actions-project/task-api:latest",
      "versioned": "ghcr.io/tourem/github-actions-project/task-api:1.0-SNAPSHOT"
    }
  }
}
```

### 6. Section `deployment`

Métadonnées du build :

```json
{
  "deployment": {
    "environment": "dev",
    "timestamp": "2025-11-03T21:35:11Z",
    "buildNumber": "42",
    "commitSha": "b9ed644abc123...",
    "branch": "main"
  }
}
```

---

## 🚀 Génération Automatique

### Workflow GitHub Actions

Le job `generate-deployment-descriptors` s'exécute automatiquement après le build :

```yaml
generate-deployment-descriptors:
  name: Generate Deployment Descriptors
  needs: build-and-deploy
  runs-on: ubuntu-latest
  
  strategy:
    matrix:
      module: [task-api, task-batch]
  
  steps:
    - name: Generate deployment descriptor
      run: |
        ./scripts/generate-deployment-descriptor.sh \
          "${{ matrix.module }}" \
          "${{ steps.get-version.outputs.version }}" \
          "${{ github.event.inputs.environment || 'dev' }}" \
          "ghcr.io"
```

### Déclenchement

Le job s'exécute :
- ✅ Après un push sur `main` ou `develop`
- ✅ Après un déclenchement manuel (`workflow_dispatch`)
- ✅ Uniquement si le build a réussi

### Actions Effectuées

1. **Génération** : Crée le fichier JSON avec toutes les informations
2. **Upload** : Upload le fichier comme artifact GitHub (rétention 90 jours)
3. **Commit** : Commit et push le fichier dans le repository
4. **Summary** : Affiche le contenu dans le résumé GitHub Actions

---

## 🛠️ Génération Manuelle

Vous pouvez générer les descripteurs manuellement :

```bash
# Pour task-api
./scripts/generate-deployment-descriptor.sh task-api 1.0-SNAPSHOT dev ghcr.io

# Pour task-batch
./scripts/generate-deployment-descriptor.sh task-batch 1.0-SNAPSHOT prd ghcr.io
```

**Paramètres** :
1. `module-name` : Nom du module (task-api, task-batch)
2. `version` : Version Maven (ex: 1.0-SNAPSHOT)
3. `environment` : Environnement cible (dev, hml, prd)
4. `docker-registry` : Registry Docker (ex: ghcr.io)
5. `maven-registry` : Registry Maven (optionnel)

---

## 📖 Utilisation pour le Déploiement

### Exemple : Déployer task-api en DEV

```bash
# 1. Lire le descripteur
DESCRIPTOR="task-api/deploy/deployment-descriptor-task-api.json"

# 2. Extraire les informations
IMAGE=$(jq -r '.docker.tags.versioned' "$DESCRIPTOR")
CONFIG_URL=$(jq -r '.configurations.dev.url' "$DESCRIPTOR")
SPRING_PROFILE=$(jq -r '.springProfiles.dev' "$DESCRIPTOR")

# 3. Télécharger la configuration
curl -H "Authorization: token $GITHUB_TOKEN" \
     -L "$CONFIG_URL" \
     -o config-dev.zip

# 4. Déployer avec Docker
docker run -d \
  -e SPRING_PROFILES_ACTIVE="$SPRING_PROFILE" \
  -v $(pwd)/config-dev:/config \
  "$IMAGE"
```

### Exemple : Script de Déploiement Automatisé

```bash
#!/bin/bash

MODULE="task-api"
ENV="dev"
DESCRIPTOR="${MODULE}/deploy/deployment-descriptor-${MODULE}.json"

# Vérifier que le descripteur existe
if [ ! -f "$DESCRIPTOR" ]; then
    echo "❌ Descripteur non trouvé: $DESCRIPTOR"
    exit 1
fi

# Extraire les informations
IMAGE=$(jq -r '.docker.tags.versioned' "$DESCRIPTOR")
CONFIG_URL=$(jq -r ".configurations.${ENV}.url" "$DESCRIPTOR")
SPRING_PROFILE=$(jq -r ".springProfiles.${ENV}" "$DESCRIPTOR")
VERSION=$(jq -r '.module.version' "$DESCRIPTOR")

echo "📦 Déploiement de ${MODULE} v${VERSION} en ${ENV}"
echo "   Image: ${IMAGE}"
echo "   Profil Spring: ${SPRING_PROFILE}"
echo "   Configuration: ${CONFIG_URL}"

# Télécharger et déployer...
```

---

## 🔍 Validation du Descripteur

### Vérifier la Structure

```bash
# Vérifier que le JSON est valide
jq . task-api/deploy/deployment-descriptor-task-api.json

# Extraire des informations spécifiques
jq '.module.version' task-api/deploy/deployment-descriptor-task-api.json
jq '.docker.tags.versioned' task-api/deploy/deployment-descriptor-task-api.json
jq '.configurations.dev.url' task-api/deploy/deployment-descriptor-task-api.json
```

### Vérifier les URLs

```bash
# Tester l'URL du JAR
JAR_URL=$(jq -r '.artifacts.jar.url' task-api/deploy/deployment-descriptor-task-api.json)
curl -I -H "Authorization: token $GITHUB_TOKEN" "$JAR_URL"

# Tester l'URL de la configuration
CONFIG_URL=$(jq -r '.configurations.dev.url' task-api/deploy/deployment-descriptor-task-api.json)
curl -I -H "Authorization: token $GITHUB_TOKEN" "$CONFIG_URL"
```

---

## 📊 Exemple Complet

Voici un exemple complet de descripteur généré :

```json
{
  "module": {
    "name": "task-api",
    "version": "1.0-SNAPSHOT",
    "groupId": "com.larbotech",
    "artifactId": "task-api"
  },
  "springProfiles": {
    "dev": "dev",
    "hml": "hml",
    "prd": "prd"
  },
  "artifacts": {
    "jar": {
      "groupId": "com.larbotech",
      "artifactId": "task-api",
      "version": "1.0-SNAPSHOT",
      "type": "jar",
      "url": "https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-api/1.0-SNAPSHOT/task-api-1.0-SNAPSHOT.jar"
    },
    "distribution": {
      "groupId": "com.larbotech",
      "artifactId": "task-api",
      "version": "1.0-SNAPSHOT",
      "type": "zip",
      "classifier": "distribution",
      "url": "https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-api/1.0-SNAPSHOT/task-api-1.0-SNAPSHOT-distribution.zip"
    }
  },
  "configurations": {
    "dev": {
      "groupId": "com.larbotech",
      "artifactId": "task-api",
      "version": "1.0-SNAPSHOT",
      "type": "zip",
      "classifier": "conf-dev",
      "url": "https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-api/1.0-SNAPSHOT/task-api-1.0-SNAPSHOT-conf-dev.zip",
      "vaultFile": "vault-dev.yml"
    },
    "hml": {
      "groupId": "com.larbotech",
      "artifactId": "task-api",
      "version": "1.0-SNAPSHOT",
      "type": "zip",
      "classifier": "conf-hml",
      "url": "https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-api/1.0-SNAPSHOT/task-api-1.0-SNAPSHOT-conf-hml.zip",
      "vaultFile": "vault-hml.yml"
    },
    "prd": {
      "groupId": "com.larbotech",
      "artifactId": "task-api",
      "version": "1.0-SNAPSHOT",
      "type": "zip",
      "classifier": "conf-prd",
      "url": "https://maven.pkg.github.com/tourem/github-actions-project/com/larbotech/task-api/1.0-SNAPSHOT/task-api-1.0-SNAPSHOT-conf-prd.zip",
      "vaultFile": "vault-prd.yml"
    }
  },
  "docker": {
    "registry": "ghcr.io",
    "repository": "tourem/github-actions-project",
    "image": "ghcr.io/tourem/github-actions-project/task-api",
    "tags": {
      "version": "1.0-SNAPSHOT",
      "latest": "ghcr.io/tourem/github-actions-project/task-api:latest",
      "versioned": "ghcr.io/tourem/github-actions-project/task-api:1.0-SNAPSHOT"
    }
  },
  "deployment": {
    "environment": "dev",
    "timestamp": "2025-11-03T21:35:11Z",
    "buildNumber": "42",
    "commitSha": "b9ed644abc123def456...",
    "branch": "main"
  }
}
```

---

## ✅ Avantages

1. **Traçabilité** : Toutes les informations de déploiement en un seul fichier
2. **Automatisation** : Génération automatique à chaque build
3. **Versioning** : Committé dans Git pour historique complet
4. **Simplicité** : Format JSON facile à parser et utiliser
5. **Flexibilité** : Supporte tous les environnements (dev, hml, prd)

---

## 🔗 Fichiers Associés

- **Script de génération** : `scripts/generate-deployment-descriptor.sh`
- **Workflow CI/CD** : `.github/workflows/ci.yml`
- **Descripteurs** :
  - `task-api/deploy/deployment-descriptor-task-api.json`
  - `task-batch/deploy/deployment-descriptor-task-batch.json`

---

**Les descripteurs de déploiement simplifient et automatisent le processus de déploiement ! 🚀**


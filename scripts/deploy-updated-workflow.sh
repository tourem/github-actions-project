#!/bin/bash

###############################################################################
# Script: deploy-updated-workflow.sh
# Description: Déploie le workflow mis à jour vers github-actions-common
###############################################################################

set -e

echo "🚀 Déploiement du workflow mis à jour vers github-actions-common"
echo ""

# Configuration
REPO_URL="https://github.com/tourem/github-actions-common.git"
TEMP_DIR="/tmp/github-actions-common-update"
WORKFLOW_FILE="github-actions-common-updated/maven-docker-build.yml"
DETECT_SCRIPT="scripts/detect-modules.sh"
DESCRIPTOR_SCRIPT="scripts/generate-deployment-descriptor.sh"
SETTINGS_FILE=".github/workflows/settings.xml"

# Vérifier que les fichiers existent
if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "❌ Fichier workflow non trouvé: $WORKFLOW_FILE"
    exit 1
fi

if [ ! -f "$DETECT_SCRIPT" ]; then
    echo "❌ Fichier script non trouvé: $DETECT_SCRIPT"
    exit 1
fi

if [ ! -f "$DESCRIPTOR_SCRIPT" ]; then
    echo "❌ Fichier script non trouvé: $DESCRIPTOR_SCRIPT"
    exit 1
fi

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "❌ Fichier settings.xml non trouvé: $SETTINGS_FILE"
    exit 1
fi

# Nettoyer le répertoire temporaire s'il existe
if [ -d "$TEMP_DIR" ]; then
    echo "🧹 Nettoyage du répertoire temporaire..."
    rm -rf "$TEMP_DIR"
fi

# Créer le répertoire temporaire
mkdir -p "$TEMP_DIR"

# Initialiser le repository Git
echo "📦 Initialisation du repository..."
cd "$TEMP_DIR"
git init
git config user.name "GitHub Actions"
git config user.email "actions@github.com"

# Créer la structure de répertoires
mkdir -p .github/workflows
mkdir -p scripts

# Copier les fichiers
echo "📋 Copie des fichiers..."
cp "${OLDPWD}/${WORKFLOW_FILE}" .github/workflows/maven-docker-build.yml
cp "${OLDPWD}/${DETECT_SCRIPT}" scripts/detect-modules.sh
cp "${OLDPWD}/${DESCRIPTOR_SCRIPT}" scripts/generate-deployment-descriptor.sh
cp "${OLDPWD}/${SETTINGS_FILE}" settings.xml
chmod +x scripts/detect-modules.sh
chmod +x scripts/generate-deployment-descriptor.sh

# Créer un README
cat > README.md <<'EOF'
# GitHub Actions Common Workflows

Ce repository contient des workflows GitHub Actions réutilisables.

## Workflows Disponibles

### maven-docker-build.yml

Workflow réutilisable pour :
- Build Maven multi-modules
- Publication des artifacts sur GitHub Packages
- Build et push des images Docker sur GHCR
- Génération automatique des descripteurs de déploiement

#### Utilisation

```yaml
jobs:
  build-and-deploy:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      java-version: '21'
      maven-version: '3.9'
      dockerfile-repo: 'tourem/docker-file-common'
      docker-modules: |
        [
          {
            "name": "task-api",
            "artifact": "com.larbotech:task-api:jar",
            "config": "com.larbotech:task-api:zip:conf-dev"
          }
        ]
      deployment-descriptors-enabled: true
      deployment-environment: 'dev'
    secrets: inherit
```

#### Inputs

- `java-version`: Version de Java (requis)
- `maven-version`: Version de Maven (défaut: 3.9)
- `maven-pom`: Chemin vers pom.xml (défaut: pom.xml)
- `dockerfile-repo`: Repository contenant le Dockerfile (requis)
- `dockerfile-branch`: Branche du repository Dockerfile (défaut: main)
- `docker-modules`: JSON array des modules à builder (requis)
- `skip-tests`: Skip les tests Maven (défaut: false)
- `docker-build-enabled`: Activer le build Docker (défaut: true)
- `deployment-descriptors-enabled`: Activer la génération des descripteurs (défaut: true)
- `deployment-environment`: Environnement de déploiement (défaut: dev)
- `maven-registry`: URL du registry Maven (auto-détecté)
- `docker-registry`: URL du registry Docker (défaut: ghcr.io)

#### Outputs

- `version`: Version Maven du projet
- `docker-images`: Liste des images Docker buildées

## Scripts

### detect-modules.sh

Script pour auto-détecter les modules Maven déployables.

#### Usage

```bash
./scripts/detect-modules.sh <pom-file> <environment> [output-file]
```

#### Exemple

```bash
./scripts/detect-modules.sh pom.xml dev
```

#### Critères de Détection

Un module est considéré comme déployable s'il remplit au moins un des critères :
- Présence du plugin `spring-boot-maven-plugin`
- Packaging `war` ou `ear`
- Présence du dossier `src/main/vault/`

### generate-deployment-descriptor.sh

Script pour générer les descripteurs de déploiement JSON.

#### Usage

```bash
./scripts/generate-deployment-descriptor.sh <module-name> <version> <environment> <docker-registry> [maven-registry]
```

#### Exemple

```bash
./scripts/generate-deployment-descriptor.sh task-api 1.0-SNAPSHOT dev ghcr.io
```

## Descripteurs de Déploiement

Les descripteurs de déploiement sont des fichiers JSON générés automatiquement contenant :

1. **Module** : Informations de base (name, version, groupId, artifactId)
2. **Spring Profiles** : Profils détectés automatiquement
3. **Artifacts** : URLs des JARs et distributions
4. **Configurations** : URLs des configurations par environnement
5. **Docker** : Informations sur les images Docker
6. **Deployment** : Métadonnées du build

### Structure du Descripteur

```json
{
  "module": { ... },
  "springProfiles": { ... },
  "artifacts": { ... },
  "configurations": {
    "dev": { ... },
    "hml": { ... },
    "prd": { ... }
  },
  "docker": { ... },
  "deployment": { ... }
}
```

## Prérequis

Les projets utilisant ce workflow doivent avoir :

1. Un script `scripts/generate-deployment-descriptor.sh` dans leur repository
2. Des profils Spring dans `src/main/resources/application-{env}.yml`
3. Des configurations Vault dans `src/main/vault/vault-{env}.yml`
4. Des assemblies Maven pour générer les ZIPs de configuration

## License

MIT
EOF

# Créer un .gitignore
cat > .gitignore <<'EOF'
# IDE
.idea/
.vscode/
*.iml

# OS
.DS_Store
Thumbs.db

# Temporary files
*.tmp
*.log
EOF

# Commit initial
echo "💾 Commit des fichiers..."
git add .
git commit -m "feat: add reusable workflow with auto-detection and deployment descriptors

- Add maven-docker-build.yml workflow
- Add detect-modules.sh script for auto-detection of deployable modules
- Add generate-deployment-descriptor.sh script
- Support for deployment descriptors generation
- Auto-detection of Spring profiles
- Extract groupId dynamically from pom.xml
- Generate JSON descriptors with all deployment info"

# Ajouter le remote et push
echo "🔗 Configuration du remote..."
git remote add origin "$REPO_URL"

echo ""
echo "✅ Repository préparé dans: $TEMP_DIR"
echo ""
echo "📝 Prochaines étapes:"
echo ""
echo "1. Vérifiez le contenu du repository:"
echo "   cd $TEMP_DIR"
echo "   ls -la"
echo "   cat .github/workflows/maven-docker-build.yml"
echo ""
echo "2. Poussez vers GitHub:"
echo "   cd $TEMP_DIR"
echo "   git push -u origin main"
echo ""
echo "   ⚠️  Si le repository existe déjà, utilisez:"
echo "   git push -f origin main"
echo ""
echo "3. Nettoyez le répertoire temporaire:"
echo "   rm -rf $TEMP_DIR"
echo ""


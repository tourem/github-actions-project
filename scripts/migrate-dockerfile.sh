#!/bin/bash

# Script de migration du Dockerfile vers le repository distant
# Usage: ./migrate-dockerfile.sh

set -e

echo "🐳 Migration du Dockerfile vers docker-file-common"
echo "=================================================="
echo ""

# Variables
REMOTE_REPO="https://github.com/tourem/docker-file-common.git"
TEMP_DIR="/tmp/docker-file-common"
CURRENT_DIR=$(pwd)
DOCKERFILE_PATH="${CURRENT_DIR}/Dockerfile"

# Vérifier que le Dockerfile existe
if [ ! -f "$DOCKERFILE_PATH" ]; then
    echo "❌ Erreur: Dockerfile non trouvé dans ${DOCKERFILE_PATH}"
    exit 1
fi

echo "✅ Dockerfile trouvé: ${DOCKERFILE_PATH}"
echo ""

# Demander confirmation
read -p "Voulez-vous continuer la migration ? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Migration annulée"
    exit 1
fi

# Nettoyer le répertoire temporaire si existe
if [ -d "$TEMP_DIR" ]; then
    echo "🧹 Nettoyage du répertoire temporaire..."
    rm -rf "$TEMP_DIR"
fi

# Cloner le repository distant
echo "📥 Clonage du repository distant..."
git clone "$REMOTE_REPO" "$TEMP_DIR"

# Aller dans le répertoire
cd "$TEMP_DIR"

# Copier le Dockerfile
echo "📋 Copie du Dockerfile..."
cp "$DOCKERFILE_PATH" .

# Créer le README.md
echo "📝 Création du README.md..."
cat > README.md << 'EOF'
# Docker File Common

Repository centralisé pour les Dockerfiles partagés entre les projets Larbotech.

## Dockerfile

Dockerfile multi-stage Alpine pour applications Spring Boot.

### Arguments de Build

| Argument | Description | Format | Exemple |
|----------|-------------|--------|---------|
| `GITHUB_USER` | Nom d'utilisateur GitHub | string | `tourem` |
| `GITHUB_TOKEN` | Token d'authentification | string | `ghp_xxxxx` |
| `APP_LOCATION` | Localisation du JAR | `groupId:artifactId:version` | `com.larbotech:task-api:1.0-SNAPSHOT` |
| `CONF_LOCATION` | Localisation du ZIP | `groupId:artifactId:version` | `com.larbotech:task-api:1.0-SNAPSHOT` |

### Utilisation

```bash
docker build \
  --build-arg GITHUB_USER=tourem \
  --build-arg GITHUB_TOKEN=$GITHUB_TOKEN \
  --build-arg APP_LOCATION=com.larbotech:my-app:1.0.0 \
  --build-arg CONF_LOCATION=com.larbotech:my-app:1.0.0 \
  -t my-app:latest \
  .
```

### Caractéristiques

- ✅ Multi-stage build (Alpine JDK 21 → Alpine JRE 21)
- ✅ Téléchargement depuis GitHub Packages
- ✅ Format Maven standard (groupId:artifactId:version)
- ✅ Utilisateur non-root (java:java)
- ✅ Healthcheck intégré
- ✅ Configuration optionnelle (ZIP)

### Détails Techniques

#### Stage 1: Builder
- Base: `eclipse-temurin:21-jdk-alpine`
- Parse les variables `APP_LOCATION` et `CONF_LOCATION`
- Télécharge le JAR depuis GitHub Packages
- Télécharge le ZIP de configuration (optionnel)
- Extrait la configuration

#### Stage 2: Runtime
- Base: `eclipse-temurin:21-jre-alpine`
- Utilisateur non-root: `java:java` (UID/GID 1000)
- Healthcheck sur port 8080
- Variables d'environnement optimisées

### Variables d'Environnement

| Variable | Description | Défaut |
|----------|-------------|--------|
| `JAVA_OPTS` | Options JVM | `-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError` |
| `SPRING_PROFILES_ACTIVE` | Profil Spring Boot | `prod` |

### Ports

- `8080` : Port par défaut (configurable via `SERVER_PORT`)

## Projets Utilisant ce Dockerfile

- [github-actions-project](https://github.com/tourem/github-actions-project)

## Versioning

Ce repository suit le versioning sémantique (SemVer).

### Tags Disponibles

- `main` : Version stable la plus récente
- `develop` : Version de développement
- `v1.0.0`, `v1.1.0`, etc. : Versions spécifiques

## Contribution

Pour modifier le Dockerfile :

1. Fork le repository
2. Créer une branche (`git checkout -b feature/my-change`)
3. Commit les changements (`git commit -am 'feat: add new feature'`)
4. Push vers la branche (`git push origin feature/my-change`)
5. Créer une Pull Request

## License

MIT License - voir LICENSE pour plus de détails.

---

**Maintenu par** : Larbotech DevOps Team  
**Contact** : devops@larbotech.com
EOF

# Créer un .gitignore
echo "📝 Création du .gitignore..."
cat > .gitignore << 'EOF'
# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Temporary files
*.tmp
*.bak
EOF

# Créer un fichier LICENSE (MIT)
echo "📝 Création du LICENSE..."
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 Larbotech

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Afficher les fichiers
echo ""
echo "📁 Fichiers créés:"
ls -la

# Git add
echo ""
echo "📦 Ajout des fichiers au git..."
git add Dockerfile README.md .gitignore LICENSE

# Git status
echo ""
echo "📊 Status git:"
git status

# Demander confirmation pour le commit
echo ""
read -p "Voulez-vous commiter et pusher ? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Commit annulé"
    echo "ℹ️  Les fichiers sont dans: ${TEMP_DIR}"
    exit 0
fi

# Commit
echo "💾 Commit..."
git commit -m "feat: add multi-stage Alpine Dockerfile for Spring Boot apps

- Multi-stage build with Alpine Linux (JDK 21 → JRE 21)
- Maven coordinate format (groupId:artifactId:version)
- Downloads artifacts from GitHub Packages
- Non-root user (java:java)
- Healthcheck included
- Optional configuration ZIP support"

# Push
echo "🚀 Push vers GitHub..."
git push origin main

echo ""
echo "✅ Migration terminée avec succès !"
echo ""
echo "📍 Repository distant: ${REMOTE_REPO}"
echo "📍 Répertoire local: ${TEMP_DIR}"
echo ""
echo "🎯 Prochaines étapes:"
echo "  1. Vérifier le repository sur GitHub"
echo "  2. Tester le workflow GitHub Actions"
echo "  3. (Optionnel) Supprimer le Dockerfile local:"
echo "     cd ${CURRENT_DIR}"
echo "     git rm Dockerfile"
echo "     git commit -m 'chore: remove local Dockerfile (now using docker-file-common)'"
echo ""


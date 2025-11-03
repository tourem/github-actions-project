#!/bin/bash

# Script pour déployer github-actions-common
# Ce script prépare le repository localement
# Vous devrez créer le repository sur GitHub manuellement d'abord

set -e

echo "🚀 Préparation du déploiement de github-actions-common"
echo "======================================================"
echo ""

# Variables
PROJECT_DIR="/Users/mtoure/dev/github-actions-project"
TEMP_DIR="/tmp/github-actions-common-deploy"
GITHUB_USER="tourem"
REPO_NAME="github-actions-common"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}⚠️  IMPORTANT : Avant d'exécuter ce script${NC}"
echo "============================================"
echo ""
echo "1. Créer le repository sur GitHub :"
echo "   https://github.com/new"
echo ""
echo "2. Paramètres :"
echo "   - Repository name: ${REPO_NAME}"
echo "   - Visibility: Public"
echo "   - ⚠️  Ne PAS initialiser avec README"
echo "   - ⚠️  Ne PAS ajouter .gitignore"
echo "   - ⚠️  Ne PAS ajouter de licence"
echo ""
read -p "Avez-vous créé le repository sur GitHub ? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Veuillez d'abord créer le repository sur GitHub${NC}"
    echo ""
    echo "Allez sur : https://github.com/new"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Préparation du repository local${NC}"
echo "-----------------------------------"

# Nettoyer le dossier temporaire
if [ -d "$TEMP_DIR" ]; then
    echo "Nettoyage du dossier temporaire..."
    rm -rf "$TEMP_DIR"
fi

# Créer le dossier
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Initialiser Git
echo "Initialisation du repository Git..."
git init
git branch -M main

# Copier les fichiers
echo "Copie des fichiers depuis $PROJECT_DIR/github-actions-common/..."

# Copier tous les fichiers visibles
cp -r "$PROJECT_DIR/github-actions-common/"* . 2>/dev/null || true

# Copier le dossier .github (caché)
if [ -d "$PROJECT_DIR/github-actions-common/.github" ]; then
    cp -r "$PROJECT_DIR/github-actions-common/.github" .
    echo "✓ Dossier .github copié"
else
    echo -e "${RED}❌ Erreur: Le dossier .github n'existe pas${NC}"
    exit 1
fi

# Vérifier que le workflow existe
if [ ! -f ".github/workflows/maven-docker-build.yml" ]; then
    echo -e "${RED}❌ Erreur: Le workflow maven-docker-build.yml n'a pas été copié${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Fichiers copiés avec succès${NC}"
echo ""
echo "Contenu du repository :"
ls -la

echo ""
echo "Workflow :"
ls -la .github/workflows/

# Ajouter tous les fichiers
echo ""
echo "Ajout des fichiers à Git..."
git add .

# Commit
echo "Création du commit..."
git commit -m "feat: add reusable Maven Docker build workflow

- Add maven-docker-build.yml reusable workflow
- Add comprehensive documentation (README, USAGE)
- Add examples for different use cases
- Add Jenkinsfile comparison guide
- Support for multi-module Maven projects
- Automatic Maven and Docker registry configuration
- Automatic tagging strategy
- Support for external Dockerfile repository"

echo ""
echo -e "${GREEN}✓ Repository local créé avec succès${NC}"
echo ""
echo -e "${BLUE}📝 Prochaines étapes :${NC}"
echo "===================="
echo ""
echo "1. Ajouter le remote GitHub :"
echo -e "   ${YELLOW}cd $TEMP_DIR${NC}"
echo -e "   ${YELLOW}git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git${NC}"
echo ""
echo "2. Push vers GitHub :"
echo -e "   ${YELLOW}git push -u origin main${NC}"
echo ""
echo "3. Vérifier sur GitHub :"
echo "   https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""
echo "4. Vérifier le workflow :"
echo "   https://github.com/$GITHUB_USER/$REPO_NAME/blob/main/.github/workflows/maven-docker-build.yml"
echo ""
echo "5. Ensuite, push votre projet :"
echo -e "   ${YELLOW}cd $PROJECT_DIR${NC}"
echo -e "   ${YELLOW}git push origin main${NC}"
echo ""
echo -e "${GREEN}✨ Préparation terminée !${NC}"
echo ""
echo "Le repository est prêt dans : $TEMP_DIR"


#!/bin/bash

# Script de déploiement complet de la solution GitHub Actions
# Ce script déploie dans le bon ordre pour éviter les erreurs

set -e  # Arrêter en cas d'erreur

echo "🚀 Déploiement de la solution GitHub Actions Common"
echo "=================================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variables
GITHUB_USER="tourem"
COMMON_REPO="github-actions-common"
PROJECT_DIR="/Users/mtoure/dev/github-actions-project"
TEMP_DIR="/tmp/github-actions-deployment"

# Fonction pour afficher les étapes
step() {
    echo ""
    echo -e "${GREEN}✓ $1${NC}"
    echo "---"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

# Vérifications préalables
step "Vérifications préalables"

# Vérifier que gh est installé
if ! command -v gh &> /dev/null; then
    error "GitHub CLI (gh) n'est pas installé. Installez-le avec: brew install gh"
fi

# Vérifier que l'utilisateur est connecté
if ! gh auth status &> /dev/null; then
    error "Vous n'êtes pas connecté à GitHub. Exécutez: gh auth login"
fi

echo "✓ GitHub CLI installé et configuré"

# Vérifier que le répertoire du projet existe
if [ ! -d "$PROJECT_DIR" ]; then
    error "Le répertoire du projet n'existe pas: $PROJECT_DIR"
fi

echo "✓ Répertoire du projet trouvé"

# Vérifier que le dossier github-actions-common existe
if [ ! -d "$PROJECT_DIR/github-actions-common" ]; then
    error "Le dossier github-actions-common n'existe pas dans le projet"
fi

echo "✓ Dossier github-actions-common trouvé"

# Étape 1 : Créer le repository github-actions-common
step "Étape 1/4 : Création du repository $GITHUB_USER/$COMMON_REPO"

# Vérifier si le repository existe déjà
if gh repo view "$GITHUB_USER/$COMMON_REPO" &> /dev/null; then
    warning "Le repository $GITHUB_USER/$COMMON_REPO existe déjà"
    read -p "Voulez-vous continuer et écraser le contenu ? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "Déploiement annulé"
    fi
else
    echo "Création du repository $GITHUB_USER/$COMMON_REPO..."
    gh repo create "$GITHUB_USER/$COMMON_REPO" \
        --public \
        --description "Reusable GitHub Actions workflows for Maven and Docker builds" \
        || error "Échec de la création du repository"
    echo "✓ Repository créé"
fi

# Étape 2 : Cloner et déployer github-actions-common
step "Étape 2/4 : Déploiement du workflow réutilisable"

# Nettoyer le répertoire temporaire
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Cloner le repository
echo "Clonage du repository..."
cd "$TEMP_DIR"
git clone "https://github.com/$GITHUB_USER/$COMMON_REPO.git" || error "Échec du clonage"
cd "$COMMON_REPO"

# Copier les fichiers
echo "Copie des fichiers..."
cp -r "$PROJECT_DIR/github-actions-common/"* . || error "Échec de la copie des fichiers"

# Vérifier la structure
echo "Vérification de la structure..."
if [ ! -f ".github/workflows/maven-docker-build.yml" ]; then
    error "Le workflow réutilisable n'a pas été copié correctement"
fi

echo "✓ Fichiers copiés"

# Commit et push
echo "Commit et push..."
git add .
git commit -m "feat: add reusable Maven Docker build workflow

- Add maven-docker-build.yml reusable workflow
- Add comprehensive documentation (README, USAGE)
- Add examples for different use cases
- Add Jenkinsfile comparison guide
- Support for multi-module Maven projects
- Automatic Maven and Docker registry configuration
- Automatic tagging strategy
- Support for external Dockerfile repository" || warning "Rien à committer (peut-être déjà fait)"

git push -u origin main || error "Échec du push"

echo "✓ Workflow réutilisable déployé"

# Étape 3 : Vérifier que le workflow est accessible
step "Étape 3/4 : Vérification du déploiement"

echo "Vérification que le workflow est accessible..."
sleep 2  # Attendre que GitHub synchronise

if gh api "repos/$GITHUB_USER/$COMMON_REPO/contents/.github/workflows/maven-docker-build.yml" &> /dev/null; then
    echo "✓ Workflow réutilisable accessible"
else
    error "Le workflow n'est pas accessible. Vérifiez manuellement sur GitHub."
fi

# Étape 4 : Push du projet actuel
step "Étape 4/4 : Déploiement du projet actuel"

cd "$PROJECT_DIR"

# Vérifier qu'il y a des changements à committer
if git diff --cached --quiet && git diff --quiet; then
    warning "Aucun changement à committer dans le projet"
else
    echo "Ajout des fichiers..."
    git add .
    
    echo "Commit..."
    git commit -m "refactor: migrate to reusable workflow

- Replace complex workflow with simple configuration
- Use $GITHUB_USER/$COMMON_REPO reusable workflow
- Keep old workflow as backup (ci-old.yml)
- Reduce configuration from 200+ lines to 55 lines
- Add comprehensive migration documentation" || warning "Rien à committer"
    
    echo "Push vers GitHub..."
    git push origin main || error "Échec du push"
    
    echo "✓ Projet déployé"
fi

# Résumé final
step "✅ Déploiement terminé avec succès !"

echo ""
echo "📊 Résumé"
echo "========="
echo ""
echo "✓ Repository créé : https://github.com/$GITHUB_USER/$COMMON_REPO"
echo "✓ Workflow réutilisable : https://github.com/$GITHUB_USER/$COMMON_REPO/blob/main/.github/workflows/maven-docker-build.yml"
echo "✓ Documentation : https://github.com/$GITHUB_USER/$COMMON_REPO/blob/main/README.md"
echo "✓ Projet mis à jour : https://github.com/$GITHUB_USER/github-actions-project"
echo ""
echo "🎯 Prochaines étapes"
echo "==================="
echo ""
echo "1. Vérifier le workflow sur GitHub Actions :"
echo "   https://github.com/$GITHUB_USER/github-actions-project/actions"
echo ""
echo "2. Faire un push pour déclencher le workflow :"
echo "   cd $PROJECT_DIR"
echo "   git commit --allow-empty -m 'test: trigger workflow'"
echo "   git push origin main"
echo ""
echo "3. Vérifier les logs et les résultats"
echo ""
echo "4. Après validation (1-2 semaines), supprimer le backup :"
echo "   git rm .github/workflows/ci-old.yml"
echo "   git commit -m 'chore: remove old workflow'"
echo "   git push origin main"
echo ""

# Nettoyer
rm -rf "$TEMP_DIR"

echo "✨ Terminé !"


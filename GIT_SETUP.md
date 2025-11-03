# Configuration Git et Push vers GitHub

Ce guide vous aide à configurer Git et pousser le projet vers GitHub.

## 📋 Prérequis

- Git installé sur votre machine
- Compte GitHub (tourem)
- Repository créé sur GitHub : `github-actions-project`

## 🚀 Initialisation du Repository

### 1. Vérifier l'état actuel

```bash
# Vérifier si Git est déjà initialisé
git status

# Si pas initialisé, initialiser Git
git init
```

### 2. Configurer Git (si nécessaire)

```bash
# Configurer votre nom
git config --global user.name "Votre Nom"

# Configurer votre email
git config --global user.email "votre.email@example.com"

# Vérifier la configuration
git config --list
```

### 3. Créer le repository sur GitHub

Si ce n'est pas déjà fait :

1. Aller sur https://github.com/new
2. Nom du repository : `github-actions-project`
3. Description : "Projet multi-modules Maven avec API REST et Batch"
4. Visibilité : Public ou Private
5. **NE PAS** initialiser avec README, .gitignore ou licence
6. Cliquer sur "Create repository"

## 📤 Premier Push

### Option 1 : Repository vide (recommandé)

```bash
# Ajouter tous les fichiers
git add .

# Créer le premier commit
git commit -m "Initial commit: Multi-module Maven project with API and Batch

- Spring Boot 3 + JDK 21
- task-api: REST API for task management
- task-batch: Scheduled batch job
- GitHub Actions CI/CD pipeline
- Maven Assembly plugin for ZIP distribution"

# Ajouter le remote
git remote add origin https://github.com/tourem/github-actions-project.git

# Créer et pousser la branche main
git branch -M main
git push -u origin main
```

### Option 2 : Repository existant

```bash
# Ajouter le remote
git remote add origin https://github.com/tourem/github-actions-project.git

# Vérifier le remote
git remote -v

# Ajouter tous les fichiers
git add .

# Créer le commit
git commit -m "Add GitHub Actions CI/CD pipeline"

# Pousser vers GitHub
git push -u origin main
```

## 🔐 Authentification

### Via HTTPS (recommandé)

Utilisez un Personal Access Token (PAT) :

1. **Créer un token** :
   - Aller sur https://github.com/settings/tokens
   - Cliquer sur "Generate new token (classic)"
   - Nom : "github-actions-project"
   - Scopes : `repo`, `workflow`, `write:packages`, `read:packages`
   - Cliquer sur "Generate token"
   - **Copier le token** (vous ne le verrez qu'une fois !)

2. **Utiliser le token** :
   ```bash
   # Lors du push, utiliser le token comme mot de passe
   Username: tourem
   Password: <VOTRE_TOKEN>
   ```

3. **Sauvegarder les credentials** (optionnel) :
   ```bash
   # Configurer le cache des credentials
   git config --global credential.helper cache
   
   # Ou sauvegarder de façon permanente (moins sécurisé)
   git config --global credential.helper store
   ```

### Via SSH

1. **Générer une clé SSH** (si pas déjà fait) :
   ```bash
   ssh-keygen -t ed25519 -C "votre.email@example.com"
   ```

2. **Ajouter la clé à GitHub** :
   ```bash
   # Copier la clé publique
   cat ~/.ssh/id_ed25519.pub
   
   # Aller sur https://github.com/settings/keys
   # Cliquer sur "New SSH key"
   # Coller la clé et sauvegarder
   ```

3. **Utiliser SSH** :
   ```bash
   # Changer le remote pour SSH
   git remote set-url origin git@github.com:tourem/github-actions-project.git
   
   # Pousser
   git push -u origin main
   ```

## 🌿 Workflow Git

### Branches recommandées

```bash
# Créer la branche develop
git checkout -b develop
git push -u origin develop

# Créer une branche feature
git checkout -b feature/nouvelle-fonctionnalite
# ... faire des modifications ...
git add .
git commit -m "Add: nouvelle fonctionnalité"
git push -u origin feature/nouvelle-fonctionnalite
```

### Structure des branches

```
main (production)
  ↑
develop (développement)
  ↑
feature/* (nouvelles fonctionnalités)
hotfix/* (corrections urgentes)
```

## 📝 Conventions de Commit

### Format recommandé

```
<type>: <description courte>

<description détaillée (optionnel)>

<footer (optionnel)>
```

### Types de commit

- `feat:` - Nouvelle fonctionnalité
- `fix:` - Correction de bug
- `docs:` - Documentation
- `style:` - Formatage, point-virgules manquants, etc.
- `refactor:` - Refactoring du code
- `test:` - Ajout de tests
- `chore:` - Maintenance, dépendances, etc.
- `ci:` - Changements CI/CD

### Exemples

```bash
# Nouvelle fonctionnalité
git commit -m "feat: Add user authentication endpoint"

# Correction de bug
git commit -m "fix: Resolve null pointer exception in TaskService"

# Documentation
git commit -m "docs: Update README with deployment instructions"

# CI/CD
git commit -m "ci: Add GitHub Actions workflow for automated testing"
```

## 🔍 Vérifications Avant le Push

### Checklist

```bash
# 1. Vérifier les fichiers modifiés
git status

# 2. Vérifier les différences
git diff

# 3. Vérifier que le projet compile
mvn clean verify

# 4. Vérifier le .gitignore
cat .gitignore

# 5. Vérifier qu'aucun fichier sensible n'est inclus
git ls-files | grep -E '(password|secret|key|token)'
```

### Fichiers à ne PAS commiter

- ❌ `target/` (déjà dans .gitignore)
- ❌ `*.log` (déjà dans .gitignore)
- ❌ `*.pid` (déjà dans .gitignore)
- ❌ Fichiers IDE (`.idea/`, `.vscode/`, etc.)
- ❌ Credentials ou tokens
- ❌ Fichiers de configuration locaux

## 🎯 Après le Push

### 1. Vérifier le repository

```bash
# Ouvrir le repository dans le navigateur
open https://github.com/tourem/github-actions-project
# ou
xdg-open https://github.com/tourem/github-actions-project  # Linux
```

### 2. Vérifier GitHub Actions

```bash
# Via le navigateur
open https://github.com/tourem/github-actions-project/actions

# Via GitHub CLI
gh run list --repo tourem/github-actions-project
gh run watch --repo tourem/github-actions-project
```

### 3. Vérifier les Packages

```bash
# Via le navigateur
open https://github.com/tourem/github-actions-project/packages

# Via GitHub CLI
gh api /users/tourem/packages
```

## 🐛 Dépannage

### Erreur : "remote origin already exists"

```bash
# Supprimer le remote existant
git remote remove origin

# Ajouter le nouveau remote
git remote add origin https://github.com/tourem/github-actions-project.git
```

### Erreur : "failed to push some refs"

```bash
# Récupérer les changements distants
git pull origin main --rebase

# Résoudre les conflits si nécessaire
# Puis pousser
git push origin main
```

### Erreur : "Authentication failed"

```bash
# Vérifier le remote
git remote -v

# Utiliser un Personal Access Token
# Ou configurer SSH (voir section Authentification)
```

### Fichiers trop volumineux

```bash
# Voir les fichiers volumineux
git ls-files | xargs ls -lh | sort -k5 -h -r | head -20

# Supprimer un fichier du cache Git
git rm --cached chemin/vers/fichier

# Ajouter au .gitignore
echo "chemin/vers/fichier" >> .gitignore
```

## 📊 Commandes Git Utiles

### Voir l'historique

```bash
# Historique complet
git log

# Historique condensé
git log --oneline

# Historique graphique
git log --graph --oneline --all

# Historique d'un fichier
git log -- chemin/vers/fichier
```

### Annuler des changements

```bash
# Annuler les modifications non commitées
git checkout -- fichier

# Annuler le dernier commit (garder les changements)
git reset --soft HEAD~1

# Annuler le dernier commit (supprimer les changements)
git reset --hard HEAD~1
```

### Tags

```bash
# Créer un tag
git tag -a v1.0.0 -m "Release 1.0.0"

# Pousser les tags
git push origin --tags

# Lister les tags
git tag -l
```

## 🔄 Synchronisation

### Récupérer les changements

```bash
# Récupérer sans merger
git fetch origin

# Récupérer et merger
git pull origin main

# Récupérer et rebaser
git pull --rebase origin main
```

### Pousser les changements

```bash
# Pousser la branche courante
git push

# Pousser une branche spécifique
git push origin nom-branche

# Pousser toutes les branches
git push --all origin

# Pousser avec force (ATTENTION !)
git push --force origin main
```

## 📚 Ressources

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Docs](https://docs.github.com)
- [GitHub CLI](https://cli.github.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)

## ✅ Checklist Finale

Avant de pousser le projet :

- [ ] Git est initialisé
- [ ] Tous les fichiers sont ajoutés (`git add .`)
- [ ] Commit créé avec un message descriptif
- [ ] Remote configuré (`git remote -v`)
- [ ] Authentification configurée (PAT ou SSH)
- [ ] Projet compile (`mvn clean verify`)
- [ ] .gitignore vérifié
- [ ] Aucun fichier sensible inclus
- [ ] Repository créé sur GitHub
- [ ] Prêt à pousser !

## 🚀 Commande Finale

```bash
# Tout en une fois
git add . && \
git commit -m "Initial commit: Multi-module Maven project with GitHub Actions CI/CD" && \
git branch -M main && \
git remote add origin https://github.com/tourem/github-actions-project.git && \
git push -u origin main
```

Après le push, vérifiez :
1. ✅ Le code est sur GitHub
2. ✅ Le workflow GitHub Actions s'exécute
3. ✅ Les packages sont publiés

**Félicitations ! Votre projet est maintenant sur GitHub avec CI/CD ! 🎉**


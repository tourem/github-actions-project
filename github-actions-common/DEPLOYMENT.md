# 🚀 Déploiement du Repository github-actions-common

Guide pour déployer le repository de workflows réutilisables.

---

## 📋 Prérequis

- [ ] Accès au compte GitHub `tourem`
- [ ] Permissions pour créer un repository
- [ ] Git installé localement

---

## 🎯 Étape 1 : Créer le Repository sur GitHub

### Option A : Via l'Interface Web

1. Aller sur https://github.com/tourem
2. Cliquer sur **"New repository"**
3. Configurer :
   - **Repository name** : `github-actions-common`
   - **Description** : `Reusable GitHub Actions workflows for Maven and Docker builds`
   - **Visibility** : `Public` ou `Private` (selon votre organisation)
   - **Initialize** : ❌ Ne pas initialiser (pas de README, .gitignore, license)
4. Cliquer sur **"Create repository"**

### Option B : Via GitHub CLI

```bash
gh repo create tourem/github-actions-common \
  --public \
  --description "Reusable GitHub Actions workflows for Maven and Docker builds"
```

---

## 🎯 Étape 2 : Cloner et Initialiser

```bash
# Cloner le repository vide
cd /tmp
git clone https://github.com/tourem/github-actions-common.git
cd github-actions-common

# Initialiser si nécessaire
git init
git branch -M main
```

---

## 🎯 Étape 3 : Copier les Fichiers

```bash
# Copier tous les fichiers depuis le projet source
cp -r /Users/mtoure/dev/github-actions-project/github-actions-common/* .

# Vérifier la structure
tree -L 3
```

**Structure attendue** :
```
github-actions-common/
├── .github/
│   └── workflows/
│       └── maven-docker-build.yml
├── examples/
│   ├── simple-project.yml
│   ├── multi-module.yml
│   └── with-manual-trigger.yml
├── README.md
├── USAGE.md
├── JENKINSFILE_COMPARISON.md
└── DEPLOYMENT.md
```

---

## 🎯 Étape 4 : Commit et Push

```bash
# Ajouter tous les fichiers
git add .

# Vérifier les fichiers ajoutés
git status

# Commit
git commit -m "feat: add reusable Maven Docker build workflow

- Add maven-docker-build.yml reusable workflow
- Add comprehensive documentation (README, USAGE)
- Add examples for different use cases
- Add Jenkinsfile comparison guide
- Support for multi-module Maven projects
- Automatic Maven and Docker registry configuration
- Automatic tagging strategy
- Support for external Dockerfile repository"

# Push vers GitHub
git push -u origin main
```

---

## 🎯 Étape 5 : Vérification

### Sur GitHub

1. Aller sur https://github.com/tourem/github-actions-common
2. Vérifier que tous les fichiers sont présents
3. Vérifier que le README s'affiche correctement
4. Vérifier le workflow dans `.github/workflows/`

### Localement

```bash
# Vérifier que le repository est accessible
git ls-remote https://github.com/tourem/github-actions-common.git

# Devrait afficher :
# refs/heads/main
```

---

## 🎯 Étape 6 : Tester avec un Projet

### Dans le Projet `github-actions-project`

```bash
cd /Users/mtoure/dev/github-actions-project

# Créer une branche de test
git checkout -b test/reusable-workflow

# Renommer l'ancien workflow
git mv .github/workflows/ci.yml .github/workflows/ci-old.yml

# Renommer le nouveau workflow
git mv .github/workflows/ci-simplified.yml .github/workflows/ci.yml

# Commit
git add .
git commit -m "test: use github-actions-common reusable workflow"

# Push
git push origin test/reusable-workflow
```

### Vérifier l'Exécution

1. Aller sur https://github.com/tourem/github-actions-project/actions
2. Vérifier que le workflow s'exécute
3. Vérifier les logs
4. Vérifier que les artifacts sont publiés
5. Vérifier que les images Docker sont créées

---

## 🎯 Étape 7 : Documentation

### Créer un README pour le Repository

Le README est déjà créé dans `github-actions-common/README.md`.

### Ajouter des Topics sur GitHub

1. Aller sur https://github.com/tourem/github-actions-common
2. Cliquer sur ⚙️ à côté de "About"
3. Ajouter les topics :
   - `github-actions`
   - `reusable-workflows`
   - `maven`
   - `docker`
   - `ci-cd`
   - `devops`

---

## 🎯 Étape 8 : Permissions (Si Repository Privé)

Si le repository est privé, les autres repositories doivent avoir accès.

### Option A : Rendre le Repository Public

```bash
# Via GitHub CLI
gh repo edit tourem/github-actions-common --visibility public
```

### Option B : Configurer les Permissions

1. Aller dans **Settings** → **Actions** → **General**
2. Sous "Access", sélectionner :
   - ✅ **Accessible from repositories in the 'tourem' organization**
3. Sauvegarder

---

## ✅ Checklist de Déploiement

### Création

- [ ] Repository `github-actions-common` créé sur GitHub
- [ ] Repository cloné localement
- [ ] Fichiers copiés depuis le projet source
- [ ] Structure vérifiée

### Commit et Push

- [ ] Fichiers ajoutés avec `git add`
- [ ] Commit créé avec message descriptif
- [ ] Push vers `origin main` réussi
- [ ] Fichiers visibles sur GitHub

### Vérification

- [ ] README s'affiche correctement
- [ ] Workflow visible dans `.github/workflows/`
- [ ] Documentation accessible
- [ ] Exemples présents

### Test

- [ ] Projet de test configuré
- [ ] Workflow s'exécute correctement
- [ ] Artifacts Maven publiés
- [ ] Images Docker créées
- [ ] Tags Docker corrects

### Documentation

- [ ] Topics ajoutés sur GitHub
- [ ] README complet
- [ ] USAGE.md détaillé
- [ ] Exemples fournis

### Permissions (si privé)

- [ ] Permissions configurées
- [ ] Autres repositories peuvent accéder

---

## 🔧 Dépannage

### Erreur : "Repository not found"

**Cause** : Le repository n'existe pas ou n'est pas accessible.

**Solution** :
1. Vérifier que le repository existe : https://github.com/tourem/github-actions-common
2. Vérifier les permissions
3. Vérifier l'URL du repository

### Erreur : "Workflow not found"

**Cause** : Le chemin du workflow est incorrect.

**Solution** :
Vérifier que le fichier existe à :
```
.github/workflows/maven-docker-build.yml
```

### Erreur : "Permission denied"

**Cause** : Pas de permissions pour accéder au workflow réutilisable.

**Solution** :
1. Rendre le repository public, ou
2. Configurer les permissions d'accès

---

## 📚 Ressources

- [GitHub Actions - Reusing Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [GitHub Actions - Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

---

## 🎯 Prochaines Étapes

Après le déploiement :

1. **Tester** avec le projet actuel
2. **Valider** les résultats
3. **Documenter** pour les équipes
4. **Migrer** les autres projets
5. **Former** les équipes

---

**Date** : 2025-11-03  
**Version** : 1.0


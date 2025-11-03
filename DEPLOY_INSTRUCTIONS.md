# 🚀 Instructions de Déploiement - github-actions-common

## ❌ Problème Actuel

Votre workflow GitHub Actions échoue avec l'erreur :
```
Error calling workflow 'tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main'
```

**Cause** : Le repository `tourem/github-actions-common` n'existe pas encore !

---

## ✅ Solution : Créer le Repository en 2 Étapes

### Étape 1 : Créer le Repository sur GitHub

1. **Aller sur GitHub** : https://github.com/new

2. **Remplir le formulaire** :
   - **Repository name** : `github-actions-common`
   - **Description** : `Reusable GitHub Actions workflows for Maven and Docker builds`
   - **Visibility** : Public ✅
   - **⚠️ IMPORTANT** : Ne PAS cocher "Add a README file"
   - **⚠️ IMPORTANT** : Ne PAS ajouter .gitignore
   - **⚠️ IMPORTANT** : Ne PAS choisir de licence

3. **Cliquer sur** : "Create repository"

4. **Copier l'URL** affichée (quelque chose comme) :
   ```
   https://github.com/tourem/github-actions-common.git
   ```

---

### Étape 2 : Déployer le Contenu

Ouvrir un terminal et exécuter :

```bash
# Aller dans un dossier temporaire
cd /tmp

# Créer un nouveau repository Git
mkdir github-actions-common
cd github-actions-common
git init
git branch -M main

# Copier les fichiers depuis votre projet
cp -r /Users/mtoure/dev/github-actions-project/github-actions-common/* .
cp -r /Users/mtoure/dev/github-actions-project/github-actions-common/.github .

# Vérifier que tout est copié
ls -la
ls -la .github/workflows/

# Vous devriez voir :
# - README.md
# - USAGE.md
# - DEPLOYMENT.md
# - JENKINSFILE_COMPARISON.md
# - examples/
# - .github/workflows/maven-docker-build.yml

# Ajouter et commiter
git add .
git commit -m "feat: add reusable Maven Docker build workflow

- Add maven-docker-build.yml reusable workflow
- Add comprehensive documentation (README, USAGE)
- Add examples for different use cases
- Add Jenkinsfile comparison guide
- Support for multi-module Maven projects
- Automatic Maven and Docker registry configuration
- Automatic tagging strategy
- Support for external Dockerfile repository"

# Ajouter le remote (remplacer par votre URL)
git remote add origin https://github.com/tourem/github-actions-common.git

# Push
git push -u origin main
```

---

### Étape 3 : Vérifier le Déploiement

1. **Aller sur** : https://github.com/tourem/github-actions-common

2. **Vérifier que vous voyez** :
   - ✅ README.md
   - ✅ .github/workflows/maven-docker-build.yml
   - ✅ Documentation complète

3. **Vérifier le workflow** :
   - Aller sur : https://github.com/tourem/github-actions-common/blob/main/.github/workflows/maven-docker-build.yml
   - Le fichier doit être visible

---

### Étape 4 : Push Votre Projet

Une fois que `github-actions-common` est déployé :

```bash
cd /Users/mtoure/dev/github-actions-project

# Vérifier l'état
git status

# Commit
git add .
git commit -m "refactor: migrate to reusable workflow

- Move old workflow to workflows-backup/
- Use tourem/github-actions-common reusable workflow
- Reduce configuration from 200+ lines to 55 lines
- Add comprehensive migration documentation"

# Push
git push origin main
```

---

## 🎯 Ordre Important

**⚠️ TRÈS IMPORTANT** : Respecter cet ordre !

1. ✅ **D'abord** : Créer et déployer `github-actions-common`
2. ✅ **Ensuite** : Push votre projet `github-actions-project`

**Si vous inversez l'ordre**, le workflow échouera car il ne trouvera pas le workflow réutilisable !

---

## 🔍 Vérification Rapide

Avant de push votre projet, vérifiez que le workflow réutilisable est accessible :

```bash
# Vérifier que le repository existe
curl -s https://api.github.com/repos/tourem/github-actions-common | grep -q '"name": "github-actions-common"' && echo "✅ Repository existe" || echo "❌ Repository n'existe pas"

# Vérifier que le workflow existe
curl -s https://api.github.com/repos/tourem/github-actions-common/contents/.github/workflows/maven-docker-build.yml | grep -q '"name": "maven-docker-build.yml"' && echo "✅ Workflow existe" || echo "❌ Workflow n'existe pas"
```

---

## 📋 Checklist

- [ ] Créer le repository `github-actions-common` sur GitHub
- [ ] Copier les fichiers dans un dossier temporaire
- [ ] Commit et push vers `github-actions-common`
- [ ] Vérifier que le workflow est visible sur GitHub
- [ ] Push le projet `github-actions-project`
- [ ] Vérifier que le workflow s'exécute correctement

---

## 🆘 En Cas de Problème

### Problème : "Repository not found"

**Solution** : Vérifier que le repository est bien public et que le nom est exact : `tourem/github-actions-common`

### Problème : "Workflow not found"

**Solution** : Vérifier que le fichier est bien à l'emplacement : `.github/workflows/maven-docker-build.yml`

### Problème : "Permission denied"

**Solution** : Vérifier que vous avez les droits d'accès au repository

---

## 📞 Commandes Utiles

```bash
# Vérifier l'URL du remote
git remote -v

# Vérifier la branche actuelle
git branch

# Vérifier les fichiers qui seront commités
git status

# Voir le contenu d'un commit
git show HEAD
```

---

**Date** : 2025-11-03  
**Version** : 1.0


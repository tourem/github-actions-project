# 🔧 Fix : Erreur de Build GitHub Actions

## ❌ Erreur Actuelle

```
Invalid workflow file

The workflow is not valid. .github/workflows/ci.yml (Line: 21, Col: 3): 
Error calling workflow 'tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main'. 
The nested job 'bui...
```

---

## 🔍 Cause du Problème

Le workflow `.github/workflows/ci.yml` fait référence à un workflow réutilisable :

```yaml
jobs:
  build-and-deploy:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
```

**Mais** le repository `tourem/github-actions-common` **n'existe pas encore** ! 🚨

---

## ✅ Solution : Créer le Repository en 3 Étapes

### Étape 1 : Créer le Repository sur GitHub (Manuel)

1. **Aller sur** : https://github.com/new

2. **Remplir** :
   - **Repository name** : `github-actions-common`
   - **Description** : `Reusable GitHub Actions workflows for Maven and Docker builds`
   - **Visibility** : **Public** ✅
   
3. **⚠️ IMPORTANT - Ne PAS cocher** :
   - ❌ "Add a README file"
   - ❌ "Add .gitignore"
   - ❌ "Choose a license"

4. **Cliquer** : "Create repository"

---

### Étape 2 : Déployer le Workflow Réutilisable (Script)

Exécuter le script fourni :

```bash
cd /Users/mtoure/dev/github-actions-project
./deploy-github-actions-common.sh
```

Le script va :
- ✅ Créer un repository Git local dans `/tmp/github-actions-common-deploy`
- ✅ Copier tous les fichiers de `github-actions-common/`
- ✅ Créer un commit
- ✅ Vous donner les commandes pour push

**Ensuite, suivre les instructions affichées** :

```bash
cd /tmp/github-actions-common-deploy
git remote add origin https://github.com/tourem/github-actions-common.git
git push -u origin main
```

---

### Étape 3 : Vérifier et Push Votre Projet

1. **Vérifier que le workflow est accessible** :
   - Aller sur : https://github.com/tourem/github-actions-common
   - Vérifier que `.github/workflows/maven-docker-build.yml` existe

2. **Push votre projet** :
   ```bash
   cd /Users/mtoure/dev/github-actions-project
   git push origin main
   ```

3. **Vérifier le build** :
   - Aller sur : https://github.com/tourem/github-actions-project/actions
   - Le workflow devrait s'exécuter sans erreur ✅

---

## 📋 Ordre d'Exécution (IMPORTANT)

```
1. Créer github-actions-common sur GitHub
   ↓
2. Déployer le workflow réutilisable
   ↓
3. Vérifier que le workflow est accessible
   ↓
4. Push github-actions-project
   ↓
5. ✅ Build réussi !
```

**⚠️ Si vous inversez l'ordre, le build échouera !**

---

## 🎯 Commandes Complètes

### Option A : Avec le Script (Recommandé)

```bash
# 1. Créer le repository sur GitHub (manuel)
# Aller sur https://github.com/new

# 2. Exécuter le script
cd /Users/mtoure/dev/github-actions-project
./deploy-github-actions-common.sh

# 3. Suivre les instructions du script
cd /tmp/github-actions-common-deploy
git remote add origin https://github.com/tourem/github-actions-common.git
git push -u origin main

# 4. Vérifier
open https://github.com/tourem/github-actions-common

# 5. Push le projet
cd /Users/mtoure/dev/github-actions-project
git push origin main
```

---

### Option B : Manuel (Sans Script)

```bash
# 1. Créer le repository sur GitHub (manuel)
# Aller sur https://github.com/new

# 2. Préparer le repository local
cd /tmp
mkdir github-actions-common
cd github-actions-common
git init
git branch -M main

# 3. Copier les fichiers
cp -r /Users/mtoure/dev/github-actions-project/github-actions-common/* .
cp -r /Users/mtoure/dev/github-actions-project/github-actions-common/.github .

# 4. Vérifier
ls -la .github/workflows/
# Vous devriez voir : maven-docker-build.yml

# 5. Commit
git add .
git commit -m "feat: add reusable Maven Docker build workflow"

# 6. Push
git remote add origin https://github.com/tourem/github-actions-common.git
git push -u origin main

# 7. Vérifier
open https://github.com/tourem/github-actions-common

# 8. Push le projet
cd /Users/mtoure/dev/github-actions-project
git push origin main
```

---

## 🔍 Vérifications

### Vérifier que github-actions-common est accessible

```bash
# Vérifier le repository
curl -s https://api.github.com/repos/tourem/github-actions-common | grep '"name"'

# Vérifier le workflow
curl -s https://api.github.com/repos/tourem/github-actions-common/contents/.github/workflows/maven-docker-build.yml | grep '"name"'
```

**Résultat attendu** :
```json
"name": "github-actions-common"
"name": "maven-docker-build.yml"
```

---

## 🆘 Dépannage

### Erreur : "Repository not found"

**Cause** : Le repository n'existe pas ou n'est pas public

**Solution** :
1. Vérifier sur : https://github.com/tourem/github-actions-common
2. Vérifier que le repository est **Public**
3. Vérifier le nom exact : `github-actions-common`

---

### Erreur : "Workflow not found"

**Cause** : Le fichier workflow n'est pas au bon endroit

**Solution** :
1. Vérifier que le fichier existe : `.github/workflows/maven-docker-build.yml`
2. Vérifier sur GitHub : https://github.com/tourem/github-actions-common/blob/main/.github/workflows/maven-docker-build.yml

---

### Erreur : "Permission denied"

**Cause** : Problème d'authentification Git

**Solution** :
```bash
# Vérifier l'authentification
git config --global user.name
git config --global user.email

# Si nécessaire, configurer
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"
```

---

## 📊 Résumé

| Étape | Action | Status |
|-------|--------|--------|
| 1 | Créer `github-actions-common` sur GitHub | ⏳ À faire |
| 2 | Déployer le workflow réutilisable | ⏳ À faire |
| 3 | Vérifier l'accessibilité | ⏳ À faire |
| 4 | Push `github-actions-project` | ⏳ À faire |
| 5 | Vérifier le build | ⏳ À faire |

---

## 🎯 Fichiers Créés pour Vous Aider

- ✅ `deploy-github-actions-common.sh` - Script de déploiement automatique
- ✅ `DEPLOY_INSTRUCTIONS.md` - Instructions détaillées
- ✅ `FIX_BUILD_ERROR.md` - Ce fichier

---

## 📞 Commandes Rapides

```bash
# Déployer github-actions-common
./deploy-github-actions-common.sh

# Vérifier le status
git status

# Push le projet (après avoir déployé github-actions-common)
git push origin main

# Voir les logs du workflow
# Aller sur : https://github.com/tourem/github-actions-project/actions
```

---

**Une fois `github-actions-common` déployé, votre build passera ! ✅**

---

**Date** : 2025-11-03  
**Version** : 1.0


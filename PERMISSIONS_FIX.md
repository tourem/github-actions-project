# 🔧 Correction des Permissions - Workflow GitHub Actions

## ❌ Erreur Rencontrée

```
Invalid workflow file: .github/workflows/ci.yml#L30
The workflow is not valid. .github/workflows/ci.yml (Line: 30, Col: 3): 
Error calling workflow 'tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main'. 
The nested job 'generate-deployment-descriptors' is requesting 'contents: write', 
but is only allowed 'contents: read'.
```

---

## 🔍 Cause du Problème

Le job `generate-deployment-descriptors` dans le workflow partagé a besoin de la permission `contents: write` pour :
- ✅ Commiter les descripteurs de déploiement
- ✅ Pusher vers le repository

Mais le workflow local ne donnait que la permission `contents: read`.

---

## ✅ Solution Appliquée

### Avant

```yaml
jobs:
  build-and-deploy:
    name: Build and Deploy
    permissions:
      contents: read      # ❌ Lecture seule
      packages: write
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
```

### Après

```yaml
jobs:
  build-and-deploy:
    name: Build and Deploy
    permissions:
      contents: write     # ✅ Lecture + Écriture
      packages: write
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
```

---

## 📋 Permissions Nécessaires

| Permission | Niveau | Utilisation |
|------------|--------|-------------|
| `contents` | `write` | Commiter et pusher les descripteurs de déploiement |
| `packages` | `write` | Publier les artifacts Maven et les images Docker |

---

## 🔐 Sécurité

La permission `contents: write` est nécessaire uniquement pour :
- ✅ Le job `generate-deployment-descriptors`
- ✅ Commiter les fichiers JSON dans `{module}/deploy/`

Elle est **héritée** par tous les jobs du workflow partagé grâce à `secrets: inherit`.

---

## ✅ Résultat

- ✅ **Permission corrigée** : `contents: write`
- ✅ **Commit réussi** : `0c17b80`
- ✅ **Push réussi** sur GitHub
- ✅ **Workflow validé** par GitHub Actions

---

## 🎯 Prochaines Étapes

Le workflow devrait maintenant s'exécuter correctement :

1. **Build Maven** → Compile et publie les artifacts
2. **Build Docker** → Construit et push les images
3. **Generate Descriptors** → Génère, upload et commit les descripteurs

**Vérifiez le workflow sur** : https://github.com/tourem/github-actions-project/actions

---

## 📝 Note pour les Équipes

Lors de l'utilisation du workflow partagé avec la génération des descripteurs activée, assurez-vous d'avoir :

```yaml
jobs:
  build-and-deploy:
    permissions:
      contents: write    # ✅ Requis pour commiter les descripteurs
      packages: write    # ✅ Requis pour publier les artifacts
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      deployment-descriptors-enabled: true
    secrets: inherit
```

**Sans `contents: write`, le workflow échouera lors de la génération des descripteurs !**


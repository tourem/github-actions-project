# 🐳 Migration du Dockerfile vers Repository Distant

## ✅ Modifications Effectuées

Le workflow GitHub Actions a été adapté pour utiliser le Dockerfile depuis le repository distant `https://github.com/tourem/docker-file-common.git`.

## 📝 Changements dans `.github/workflows/ci.yml`

### 1. Ajout du checkout du repository Dockerfile

```yaml
- name: Checkout Dockerfile repository
  uses: actions/checkout@v4
  with:
    repository: tourem/docker-file-common
    path: docker-file-common
```

### 2. Modification du chemin du Dockerfile

```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    context: .
    file: ./docker-file-common/Dockerfile  # ← Chemin mis à jour
    push: true
    ...
```

## 🚀 Étapes pour Finaliser la Migration

### 1. Créer le repository distant (si pas déjà fait)

```bash
# Sur GitHub, créer le repository: tourem/docker-file-common
```

### 2. Cloner le repository distant

```bash
cd /tmp
git clone https://github.com/tourem/docker-file-common.git
cd docker-file-common
```

### 3. Copier le Dockerfile

```bash
# Depuis le projet github-actions-project
cp /Users/mtoure/dev/github-actions-project/Dockerfile .
```

### 4. Créer un README pour le repository

```bash
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

## Projets Utilisant ce Dockerfile

- [github-actions-project](https://github.com/tourem/github-actions-project)

EOF
```

### 5. Commit et push

```bash
git add Dockerfile README.md
git commit -m "feat: add multi-stage Alpine Dockerfile for Spring Boot apps"
git push origin main
```

### 6. Vérifier le workflow GitHub Actions

Une fois le Dockerfile poussé sur `tourem/docker-file-common`, le workflow du projet `github-actions-project` :
1. Checkout le code du projet
2. Checkout le repository `docker-file-common`
3. Build l'image Docker avec le Dockerfile distant
4. Push l'image vers GHCR

## 📊 Structure du Workflow

```
┌─────────────────────────────────────────────────────────────┐
│              Job: build-docker-images                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Checkout github-actions-project                    │
│  └─ Récupère le code source du projet                       │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 2: Checkout docker-file-common                        │
│  └─ Récupère le Dockerfile depuis le repo distant           │
│     Path: ./docker-file-common/                             │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 3: Build Docker Image                                 │
│  └─ Context: . (projet actuel)                              │
│  └─ Dockerfile: ./docker-file-common/Dockerfile             │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Avantages de cette Approche

1. **Centralisation** : Un seul Dockerfile pour tous les projets
2. **Maintenance** : Mise à jour centralisée
3. **Cohérence** : Tous les projets utilisent la même base
4. **Versioning** : Possibilité de versionner le Dockerfile
5. **Réutilisabilité** : Facile à partager entre projets

## 📝 Optionnel : Utiliser une Version Spécifique

Si vous voulez utiliser une version spécifique du Dockerfile (tag ou branche) :

```yaml
- name: Checkout Dockerfile repository
  uses: actions/checkout@v4
  with:
    repository: tourem/docker-file-common
    ref: v1.0.0  # ou main, develop, etc.
    path: docker-file-common
```

## 🧹 Nettoyage du Projet Local

Une fois le Dockerfile migré vers le repository distant, vous pouvez supprimer le Dockerfile local :

```bash
cd /Users/mtoure/dev/github-actions-project
git rm Dockerfile
git commit -m "chore: remove local Dockerfile (now using docker-file-common)"
```

## ✅ Checklist de Migration

- [ ] Créer le repository `tourem/docker-file-common` sur GitHub
- [ ] Cloner le repository localement
- [ ] Copier le Dockerfile dans le repository
- [ ] Créer un README.md
- [ ] Commit et push vers GitHub
- [ ] Vérifier que le workflow GitHub Actions fonctionne
- [ ] (Optionnel) Supprimer le Dockerfile local du projet
- [ ] (Optionnel) Mettre à jour la documentation du projet

## 🎯 Résultat Final

Après la migration :

**Repository `docker-file-common`** :
```
docker-file-common/
├── Dockerfile
└── README.md
```

**Repository `github-actions-project`** :
```
github-actions-project/
├── .github/workflows/ci.yml  (mis à jour)
├── docker-compose.yml
├── DOCKER.md
└── ... (autres fichiers)
```

**Workflow GitHub Actions** :
- ✅ Checkout du projet
- ✅ Checkout du Dockerfile depuis `docker-file-common`
- ✅ Build avec `./docker-file-common/Dockerfile`
- ✅ Push vers GHCR

---

**Date** : 2025-11-03  
**Status** : ✅ Workflow adapté, migration en attente


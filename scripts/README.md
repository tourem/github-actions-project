# 📜 Scripts Utilitaires

Ce dossier contient tous les scripts utilitaires pour le projet.

---

## 📋 Scripts Disponibles

### 🔍 Auto-Détection et Génération

#### `detect-modules.sh`

Auto-détecte les modules Maven déployables depuis le `pom.xml`.

**Usage** :
```bash
./detect-modules.sh <pom-file> <environment> [output-file]
```

**Exemples** :
```bash
# Détecter les modules pour l'environnement dev
./detect-modules.sh pom.xml dev

# Sauvegarder dans un fichier
./detect-modules.sh pom.xml dev modules.json

# Depuis la racine du projet
./scripts/detect-modules.sh pom.xml dev
```

**Critères de détection** :
- ✅ Présence du plugin `spring-boot-maven-plugin`
- ✅ Packaging `war` ou `ear`
- ✅ Présence du dossier `src/main/vault/`

**Sortie** :
```json
[
  {
    "name": "task-api",
    "artifact": "com.larbotech:task-api:jar",
    "config": "com.larbotech:task-api:zip:conf-dev"
  }
]
```

---

#### `generate-deployment-descriptor.sh`

Génère un descripteur de déploiement JSON pour un module.

**Usage** :
```bash
./generate-deployment-descriptor.sh <module-name> <version> <environment> <registry>
```

**Exemples** :
```bash
# Générer un descripteur pour task-api
./generate-deployment-descriptor.sh task-api 1.0-SNAPSHOT dev ghcr.io

# Depuis la racine du projet
./scripts/generate-deployment-descriptor.sh task-api 1.0-SNAPSHOT dev ghcr.io
```

**Fichiers générés** :
- `{module}/deploy/deployment-descriptor-{module}-YYYYMMDD-HHMMSS.json` (avec timestamp)
- `{module}/deploy/deployment-descriptor-{module}-latest.json` (dernière version)

**Contenu du descripteur** :
```json
{
  "module": "task-api",
  "version": "1.0-SNAPSHOT",
  "environment": "dev",
  "timestamp": "2025-11-03T22:04:16Z",
  "docker": {
    "image": "ghcr.io/tourem/github-actions-project/task-api",
    "tag": "1.0-SNAPSHOT",
    "registry": "ghcr.io"
  },
  "maven": {
    "groupId": "com.larbotech",
    "artifactId": "task-api",
    "packaging": "jar"
  },
  "deployment": {
    "port": 8080,
    "profiles": ["dev"],
    "vault": {
      "enabled": true,
      "files": ["vault-dev.yml"]
    }
  }
}
```

---

### 🚀 Déploiement

#### `deploy-complete-solution.sh`

Déploie la solution complète GitHub Actions (workflow partagé + projet).

**Usage** :
```bash
./deploy-complete-solution.sh
```

**Actions** :
1. Clone le repository `github-actions-common`
2. Copie les workflows et scripts
3. Commit et push vers `github-actions-common`
4. Met à jour le projet local
5. Commit et push vers le projet

**Prérequis** :
- Repository `github-actions-common` créé sur GitHub
- Accès en écriture aux deux repositories

---

#### `deploy-github-actions-common.sh`

Prépare et déploie le repository `github-actions-common`.

**Usage** :
```bash
./deploy-github-actions-common.sh
```

**Actions** :
1. Crée un répertoire temporaire
2. Initialise un nouveau repository Git
3. Copie les workflows et scripts
4. Crée un README
5. Affiche les instructions pour pousser vers GitHub

**Note** : Vous devez créer le repository sur GitHub manuellement avant d'exécuter ce script.

---

#### `deploy-updated-workflow.sh`

Met à jour le workflow partagé dans `github-actions-common`.

**Usage** :
```bash
./deploy-updated-workflow.sh
```

**Actions** :
1. Clone `github-actions-common` dans `/tmp`
2. Copie le workflow mis à jour
3. Copie les scripts mis à jour
4. Commit et push les changements

**Fichiers mis à jour** :
- `.github/workflows/maven-docker-build.yml`
- `scripts/detect-modules.sh`
- `scripts/generate-deployment-descriptor.sh`

---

#### `migrate-dockerfile.sh`

Migre le Dockerfile vers le repository `docker-file-common`.

**Usage** :
```bash
./migrate-dockerfile.sh
```

**Actions** :
1. Vérifie que le Dockerfile existe localement
2. Clone `docker-file-common` dans `/tmp`
3. Copie le Dockerfile
4. Commit et push vers `docker-file-common`

**Prérequis** :
- Dockerfile présent à la racine du projet
- Repository `docker-file-common` créé sur GitHub

---

## 🔧 Configuration

### Variables d'Environnement

Les scripts utilisent les variables suivantes (modifiables dans chaque script) :

```bash
# Utilisateur GitHub
GITHUB_USER="tourem"

# Repositories
COMMON_REPO="github-actions-common"
DOCKERFILE_REPO="docker-file-common"

# Répertoires
PROJECT_DIR="/Users/mtoure/dev/github-actions-project"
TEMP_DIR="/tmp/github-actions-deployment"
```

### Permissions

Tous les scripts doivent être exécutables :

```bash
# Rendre tous les scripts exécutables
chmod +x scripts/*.sh

# Ou individuellement
chmod +x scripts/detect-modules.sh
chmod +x scripts/generate-deployment-descriptor.sh
```

---

## 📝 Exemples d'Utilisation

### Workflow Complet

```bash
# 1. Détecter les modules
./scripts/detect-modules.sh pom.xml dev

# 2. Générer les descripteurs pour chaque module
./scripts/generate-deployment-descriptor.sh task-api 1.0-SNAPSHOT dev ghcr.io
./scripts/generate-deployment-descriptor.sh task-batch 1.0-SNAPSHOT dev ghcr.io

# 3. Déployer la solution complète
./scripts/deploy-complete-solution.sh
```

### Mise à Jour du Workflow Partagé

```bash
# 1. Modifier le workflow dans github-actions-common-updated/
vim github-actions-common-updated/maven-docker-build.yml

# 2. Déployer les changements
./scripts/deploy-updated-workflow.sh
```

### Migration du Dockerfile

```bash
# 1. Créer/modifier le Dockerfile
vim Dockerfile

# 2. Migrer vers docker-file-common
./scripts/migrate-dockerfile.sh
```

---

## 🐛 Troubleshooting

### Script non exécutable

```bash
# Erreur: Permission denied
chmod +x scripts/detect-modules.sh
```

### xmllint non trouvé

```bash
# macOS
brew install libxml2

# Ubuntu/Debian
sudo apt-get install libxml2-utils

# CentOS/RHEL
sudo yum install libxml2
```

### jq non trouvé

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq
```

### Erreur Git

```bash
# Vérifier la configuration Git
git config --global user.name
git config --global user.email

# Configurer si nécessaire
git config --global user.name "Votre Nom"
git config --global user.email "votre@email.com"
```

---

## 📚 Documentation

Pour plus de détails, consultez :

- **[README.md](../README.md)** - Documentation principale
- **[docs/GITHUB_ACTIONS.md](../docs/GITHUB_ACTIONS.md)** - Guide GitHub Actions
- **[docs/DEPLOYMENT.md](../docs/DEPLOYMENT.md)** - Guide de déploiement
- **[docs/DOCKER.md](../docs/DOCKER.md)** - Guide Docker

---

## 🔗 Liens Utiles

- **Repository** : https://github.com/tourem/github-actions-project
- **Workflow Partagé** : https://github.com/tourem/github-actions-common
- **Dockerfile Commun** : https://github.com/tourem/docker-file-common


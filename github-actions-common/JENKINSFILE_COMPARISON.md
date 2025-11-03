# 🔄 Comparaison Jenkinsfile → GitHub Actions

Ce document compare la configuration Jenkins avec GitHub Actions pour faciliter la migration.

---

## 📊 Comparaison Côte à Côte

### Jenkinsfile (Avant)

```groovy
job_pipeline.execute(
    jfrog: true,
    mavenWithNPM: true,
    npmFixConfig: false,
    projectType: 'awt',
    javaVersion: 17,
    mavenVersion: 3.9,
    jenkinsNodeLabel: 'ocs',
    mavenPom: 'pom.xml',
    CD: 'db-intranet-deploy',
    deployModule: 'dacgestion_backend',
    dockerBuilds: [
        backend_spring: [
            deployModule: 'dacgestion_backend',
            CD: 'db-intranet-deploy',
            imageTemplateRepo: [
                url: 'https://sgithub.fr.world.socgen/X-Blocks/xbl.sofa.awt-docker-spring',
                branch: 'main'
            ],
            buildArgs: [
                JAVA_VERSION: '17',
                ARTIFACT_REFERENCE: 'com.socgen.digital.agence:dacgestion_backend:jar:${version}',
                CONF_REFERENCE: 'com.socgen.digital.agence:dacgestion_backend:zip:${version}:conf-secrets-dev'
            ],
            dockerOptions: '--no-cache --pull'
        ],
        batch_spring: [
            deployModule: 'dacgestion_batch',
            CD: 'db-intranet-deploy',
            imageTemplateRepo: [
                url: 'https://sgithub.fr.world.socgen/X-Blocks/xbl.sofa.awt-docker-spring',
                branch: 'main'
            ],
            buildArgs: [
                JAVA_VERSION: '17',
                ARTIFACT_REFERENCE: 'com.socgen.digital.agence:dacgestion_batch:jar:${version}',
                CONF_REFERENCE: 'com.socgen.digital.agence:dacgestion_batch:zip:${version}:conf-secrets-dev'
            ],
            dockerOptions: '--no-cache --pull'
        ]
    ]
)
```

### GitHub Actions (Après)

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]

jobs:
  build-and-deploy:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      # Configuration Maven
      java-version: '17'
      maven-version: '3.9'
      maven-pom: 'pom.xml'
      
      # Configuration Dockerfile
      dockerfile-repo: 'tourem/docker-file-common'
      dockerfile-branch: 'main'
      
      # Modules Docker
      docker-modules: |
        [
          {
            "name": "dacgestion-backend",
            "artifact": "com.socgen.digital.agence:dacgestion_backend:jar",
            "config": "com.socgen.digital.agence:dacgestion_backend:zip:conf-secrets-dev"
          },
          {
            "name": "dacgestion-batch",
            "artifact": "com.socgen.digital.agence:dacgestion_batch:jar",
            "config": "com.socgen.digital.agence:dacgestion_batch:zip:conf-secrets-dev"
          }
        ]
    
    secrets: inherit
```

---

## 📋 Mapping des Paramètres

| Jenkinsfile | GitHub Actions | Notes |
|-------------|----------------|-------|
| `javaVersion: 17` | `java-version: '17'` | Identique |
| `mavenVersion: 3.9` | `maven-version: '3.9'` | Identique |
| `mavenPom: 'pom.xml'` | `maven-pom: 'pom.xml'` | Identique |
| `imageTemplateRepo.url` | `dockerfile-repo: 'owner/repo'` | Format simplifié |
| `imageTemplateRepo.branch` | `dockerfile-branch: 'main'` | Identique |
| `buildArgs.JAVA_VERSION` | *(auto)* | Déduit de `java-version` |
| `buildArgs.ARTIFACT_REFERENCE` | `artifact: 'groupId:artifactId:jar'` | Sans version |
| `buildArgs.CONF_REFERENCE` | `config: 'groupId:artifactId:zip:classifier'` | Sans version |
| `dockerOptions: '--no-cache --pull'` | *(auto)* | Géré automatiquement |
| `jfrog: true` | *(N/A)* | GitHub Packages utilisé |
| `mavenWithNPM: true` | *(N/A)* | Non applicable |
| `projectType: 'awt'` | *(N/A)* | Non nécessaire |
| `jenkinsNodeLabel: 'ocs'` | *(N/A)* | GitHub runners |
| `CD: 'db-intranet-deploy'` | *(N/A)* | Géré séparément |
| `deployModule` | `name` dans `docker-modules` | Renommé |

---

## 🎯 Différences Clés

### 1. Format des Références Maven

**Jenkins** :
```groovy
ARTIFACT_REFERENCE: 'com.socgen:app:jar:${version}'
CONF_REFERENCE: 'com.socgen:app:zip:${version}:conf'
```

**GitHub Actions** :
```yaml
artifact: "com.socgen:app:jar"
config: "com.socgen:app:zip:conf"
```

**Différence** : La version est ajoutée automatiquement dans GitHub Actions.

---

### 2. Repository Dockerfile

**Jenkins** :
```groovy
imageTemplateRepo: [
    url: 'https://sgithub.fr.world.socgen/X-Blocks/xbl.sofa.awt-docker-spring',
    branch: 'main'
]
```

**GitHub Actions** :
```yaml
dockerfile-repo: 'tourem/docker-file-common'
dockerfile-branch: 'main'
```

**Différence** : Format simplifié `owner/repo` au lieu de l'URL complète.

---

### 3. Configuration Automatique

**Jenkins** : Nécessite de spécifier explicitement certains paramètres.

**GitHub Actions** : Configuration automatique de :
- ✅ Maven registry : `maven.pkg.github.com/{owner}/{repo}`
- ✅ Docker registry : `ghcr.io/{owner}/{repo}/{module}`
- ✅ Credentials : `secrets.GITHUB_TOKEN`
- ✅ Tags Docker : Calculés automatiquement
- ✅ Cache Maven : Activé automatiquement

---

## 📝 Guide de Migration Étape par Étape

### Étape 1 : Identifier les Modules

**Dans le Jenkinsfile**, cherchez `dockerBuilds` :

```groovy
dockerBuilds: [
    backend_spring: [...],
    batch_spring: [...]
]
```

**Résultat** : 2 modules (`backend_spring`, `batch_spring`)

---

### Étape 2 : Extraire les Informations

Pour chaque module, notez :

| Information | Exemple |
|-------------|---------|
| Nom du module | `backend_spring` |
| ARTIFACT_REFERENCE | `com.socgen:dacgestion_backend:jar:${version}` |
| CONF_REFERENCE | `com.socgen:dacgestion_backend:zip:${version}:conf-secrets-dev` |

---

### Étape 3 : Convertir en Format GitHub Actions

**Module `backend_spring`** :

```yaml
{
  "name": "dacgestion-backend",
  "artifact": "com.socgen.digital.agence:dacgestion_backend:jar",
  "config": "com.socgen.digital.agence:dacgestion_backend:zip:conf-secrets-dev"
}
```

**Module `batch_spring`** :

```yaml
{
  "name": "dacgestion-batch",
  "artifact": "com.socgen.digital.agence:dacgestion_batch:jar",
  "config": "com.socgen.digital.agence:dacgestion_batch:zip:conf-secrets-dev"
}
```

**Notes** :
- Retirer `${version}` (ajouté automatiquement)
- Convertir `_` en `-` dans le nom (convention)

---

### Étape 4 : Créer le Fichier GitHub Actions

Créer `.github/workflows/ci.yml` :

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]

jobs:
  build-and-deploy:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      java-version: '17'
      maven-version: '3.9'
      maven-pom: 'pom.xml'
      dockerfile-repo: 'tourem/docker-file-common'
      dockerfile-branch: 'main'
      docker-modules: |
        [
          {
            "name": "dacgestion-backend",
            "artifact": "com.socgen.digital.agence:dacgestion_backend:jar",
            "config": "com.socgen.digital.agence:dacgestion_backend:zip:conf-secrets-dev"
          },
          {
            "name": "dacgestion-batch",
            "artifact": "com.socgen.digital.agence:dacgestion_batch:jar",
            "config": "com.socgen.digital.agence:dacgestion_batch:zip:conf-secrets-dev"
          }
        ]
    secrets: inherit
```

---

## ✅ Checklist de Migration

### Préparation

- [ ] Lire la documentation GitHub Actions
- [ ] Identifier tous les modules dans le Jenkinsfile
- [ ] Noter les versions Java et Maven
- [ ] Vérifier le repository Dockerfile

### Conversion

- [ ] Créer `.github/workflows/ci.yml`
- [ ] Configurer `java-version` et `maven-version`
- [ ] Configurer `dockerfile-repo` et `dockerfile-branch`
- [ ] Convertir chaque module de `dockerBuilds` en entrée `docker-modules`
- [ ] Retirer `${version}` des références Maven
- [ ] Ajouter `secrets: inherit`

### Test

- [ ] Commit et push sur une branche de test
- [ ] Vérifier que le workflow s'exécute
- [ ] Vérifier les logs
- [ ] Vérifier que les artifacts Maven sont publiés
- [ ] Vérifier que les images Docker sont publiées
- [ ] Comparer avec les résultats Jenkins

### Validation

- [ ] Tester le déploiement avec les nouvelles images
- [ ] Valider avec l'équipe
- [ ] Merger sur la branche principale
- [ ] Désactiver le Jenkinsfile (après validation complète)

---

## 🎯 Avantages de GitHub Actions

| Aspect | Jenkins | GitHub Actions |
|--------|---------|----------------|
| **Configuration** | Groovy (complexe) | YAML (simple) |
| **Maintenance** | Pipeline partagé à maintenir | Workflow réutilisable versionné |
| **Credentials** | Configuration manuelle | Automatique (`GITHUB_TOKEN`) |
| **Registries** | Configuration manuelle | Auto-détection |
| **Cache** | Configuration manuelle | Automatique |
| **Logs** | Interface Jenkins | Interface GitHub (intégrée) |
| **Déclenchement manuel** | Paramètres Jenkins | Inputs workflow |
| **Versioning** | Pas de versioning du pipeline | Versioning Git du workflow |

---

## 📚 Ressources

- [README](./README.md) - Vue d'ensemble
- [USAGE](./USAGE.md) - Guide d'utilisation
- [Exemples](./examples/) - Exemples complets
- [Migration Strategy](../MIGRATION_STRATEGY.md) - Stratégie complète

---

**Version** : 1.0  
**Date** : 2025-11-03


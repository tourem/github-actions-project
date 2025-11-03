# 📦 GitHub Actions Common - Résumé de la Solution

## 🎯 Objectif

Créer une solution GitHub Actions réutilisable qui suit la même philosophie que Jenkins :
- ✅ **Demander le strict minimum aux équipes**
- ✅ **Partager le maximum de logique**
- ✅ **Configuration simple et déclarative**
- ✅ **Pas de connaissance technique GitHub Actions requise**

---

## 📊 Architecture

### 3 Repositories

```
1. github-actions-common/          ← Workflows réutilisables (plateforme)
   └── .github/workflows/
       └── maven-docker-build.yml

2. docker-file-common/             ← Dockerfile partagé (plateforme)
   └── Dockerfile

3. github-actions-project/         ← Projet d'équipe
   ├── .github/workflows/
   │   └── ci.yml                  ← Configuration minimale
   ├── pom.xml
   └── src/
```

### Flux de Travail

```
Équipe → ci.yml (simple) → Workflow Réutilisable → Build + Docker → GitHub Packages + GHCR
```

---

## 📝 Ce que les Équipes Fournissent

### Jenkinsfile (Avant)

```groovy
job_pipeline.execute(
    javaVersion: 17,
    mavenVersion: 3.9,
    dockerBuilds: [
        backend: [
            imageTemplateRepo: [url: '...', branch: 'main'],
            buildArgs: [
                ARTIFACT_REFERENCE: 'com.example:backend:jar:${version}',
                CONF_REFERENCE: 'com.example:backend:zip:${version}:conf'
            ]
        ]
    ]
)
```

### GitHub Actions (Après)

```yaml
jobs:
  build:
    uses: tourem/github-actions-common/.github/workflows/maven-docker-build.yml@main
    with:
      java-version: '17'
      maven-version: '3.9'
      dockerfile-repo: 'tourem/docker-file-common'
      dockerfile-branch: 'main'
      docker-modules: |
        [
          {
            "name": "backend",
            "artifact": "com.example:backend:jar",
            "config": "com.example:backend:zip:conf"
          }
        ]
    secrets: inherit
```

**Même niveau de simplicité !**

---

## ✅ Ce que les Équipes NE Fournissent PAS

Les équipes n'ont **pas besoin** de connaître ou configurer :

- ❌ URL du registry Maven (`maven.pkg.github.com`)
- ❌ URL du registry Docker (`ghcr.io`)
- ❌ Configuration des credentials (`GITHUB_TOKEN`)
- ❌ Configuration du cache Maven
- ❌ Configuration des tags Docker
- ❌ Logique de build et déploiement
- ❌ Configuration des artifacts
- ❌ Gestion des versions

**Tout cela est géré automatiquement par le workflow réutilisable !**

---

## 🚀 Workflow Réutilisable

### Responsabilités

Le workflow `maven-docker-build.yml` gère :

1. **Build Maven**
   - Setup Java (version spécifiée)
   - Setup Maven (version spécifiée)
   - Cache automatique des dépendances
   - Build et tests
   - Extraction de la version Maven
   - Publication vers GitHub Packages

2. **Build Docker**
   - Checkout du Dockerfile depuis le repository partagé
   - Build des images Docker (multi-modules en parallèle)
   - Tagging automatique :
     - `{branch}` (ex: `main`, `develop`)
     - `{branch}-{sha}` (ex: `main-abc123d`)
     - `latest` (seulement sur branche par défaut)
     - `{version}` (ex: `1.0-SNAPSHOT`)
   - Push vers GitHub Container Registry (GHCR)

3. **Configuration Automatique**
   - Maven registry : `maven.pkg.github.com/{owner}/{repo}`
   - Docker registry : `ghcr.io/{owner}/{repo}/{module}`
   - Credentials : `secrets.GITHUB_TOKEN` (automatique)

---

## 📋 Inputs du Workflow Réutilisable

### Obligatoires

| Input | Description | Exemple |
|-------|-------------|---------|
| `java-version` | Version de Java | `'21'`, `'17'` |
| `dockerfile-repo` | Repository du Dockerfile | `'tourem/docker-file-common'` |
| `docker-modules` | Modules à builder (JSON) | Voir exemples |

### Optionnels (avec valeurs par défaut)

| Input | Défaut | Description |
|-------|--------|-------------|
| `maven-version` | `'3.9'` | Version de Maven |
| `maven-pom` | `'pom.xml'` | Chemin du POM |
| `dockerfile-branch` | `'main'` | Branche du Dockerfile |
| `skip-tests` | `false` | Ignorer les tests |
| `docker-build-enabled` | `true` | Activer Docker build |
| `maven-registry` | *(auto)* | URL registry Maven |
| `docker-registry` | *(auto)* | URL registry Docker |

---

## 📚 Documentation Créée

### Dans `github-actions-common/`

```
github-actions-common/
├── .github/workflows/
│   └── maven-docker-build.yml          ← Workflow réutilisable
├── examples/
│   ├── simple-project.yml              ← Exemple 1 module
│   ├── multi-module.yml                ← Exemple multi-modules
│   └── with-manual-trigger.yml         ← Exemple avec déclenchement manuel
├── README.md                           ← Vue d'ensemble
├── USAGE.md                            ← Guide d'utilisation détaillé
└── JENKINSFILE_COMPARISON.md           ← Comparaison Jenkins vs GitHub Actions
```

### Dans le Projet

```
github-actions-project/
├── .github/workflows/
│   ├── ci.yml                          ← Workflow actuel (complexe)
│   └── ci-simplified.yml               ← Nouveau workflow (simple)
├── MIGRATION_STRATEGY.md               ← Stratégie de migration
└── GITHUB_ACTIONS_COMMON_SUMMARY.md    ← Ce fichier
```

---

## 🔄 Migration Jenkins → GitHub Actions

### Mapping des Paramètres

| Jenkinsfile | GitHub Actions |
|-------------|----------------|
| `javaVersion: 17` | `java-version: '17'` |
| `mavenVersion: 3.9` | `maven-version: '3.9'` |
| `imageTemplateRepo.url` | `dockerfile-repo: 'owner/repo'` |
| `imageTemplateRepo.branch` | `dockerfile-branch: 'main'` |
| `buildArgs.ARTIFACT_REFERENCE` | `artifact: 'groupId:artifactId:jar'` (sans version) |
| `buildArgs.CONF_REFERENCE` | `config: 'groupId:artifactId:zip:classifier'` (sans version) |

### Exemple de Conversion

**Jenkinsfile** :
```groovy
dockerBuilds: [
    backend: [
        buildArgs: [
            ARTIFACT_REFERENCE: 'com.example:backend:jar:${version}',
            CONF_REFERENCE: 'com.example:backend:zip:${version}:conf'
        ]
    ]
]
```

**GitHub Actions** :
```yaml
docker-modules: |
  [
    {
      "name": "backend",
      "artifact": "com.example:backend:jar",
      "config": "com.example:backend:zip:conf"
    }
  ]
```

**Différence** : La version est ajoutée automatiquement.

---

## 🎯 Avantages de cette Solution

### Pour les Équipes

1. ✅ **Simplicité** : Configuration minimale (comme Jenkins)
2. ✅ **Pas de connaissance GitHub Actions** requise
3. ✅ **Migration facile** : Mapping 1:1 avec Jenkinsfile
4. ✅ **Pas de gestion des credentials**
5. ✅ **Pas de configuration des registries**
6. ✅ **Déclenchement manuel** possible (test de branches Dockerfile)

### Pour la Plateforme

1. ✅ **Centralisation** : Un seul workflow à maintenir
2. ✅ **Cohérence** : Tous les projets utilisent la même logique
3. ✅ **Évolution** : Mise à jour centralisée
4. ✅ **Versioning** : Workflow versionné dans Git
5. ✅ **Bonnes pratiques** : Appliquées automatiquement
6. ✅ **Observabilité** : Logs intégrés dans GitHub

---

## 📦 Fichiers Créés

### Workflow Réutilisable

```
✅ github-actions-common/.github/workflows/maven-docker-build.yml
```

### Documentation

```
✅ github-actions-common/README.md
✅ github-actions-common/USAGE.md
✅ github-actions-common/JENKINSFILE_COMPARISON.md
```

### Exemples

```
✅ github-actions-common/examples/simple-project.yml
✅ github-actions-common/examples/multi-module.yml
✅ github-actions-common/examples/with-manual-trigger.yml
```

### Projet Simplifié

```
✅ .github/workflows/ci-simplified.yml
```

### Documentation Stratégie

```
✅ MIGRATION_STRATEGY.md
✅ GITHUB_ACTIONS_COMMON_SUMMARY.md
```

---

## 🚀 Prochaines Étapes

### Phase 1 : Création du Repository Partagé

1. Créer le repository `tourem/github-actions-common` sur GitHub
2. Copier le contenu du dossier `github-actions-common/` vers ce repository
3. Commit et push

```bash
cd /tmp
git clone https://github.com/tourem/github-actions-common.git
cd github-actions-common

# Copier les fichiers depuis github-actions-project/github-actions-common/
cp -r /Users/mtoure/dev/github-actions-project/github-actions-common/* .

git add .
git commit -m "feat: add reusable Maven Docker build workflow"
git push origin main
```

### Phase 2 : Test avec le Projet Actuel

1. Renommer `ci.yml` en `ci-old.yml`
2. Renommer `ci-simplified.yml` en `ci.yml`
3. Commit et push sur une branche de test
4. Vérifier que le workflow s'exécute correctement

```bash
cd /Users/mtoure/dev/github-actions-project

git checkout -b test/github-actions-common
git mv .github/workflows/ci.yml .github/workflows/ci-old.yml
git mv .github/workflows/ci-simplified.yml .github/workflows/ci.yml
git add .
git commit -m "test: use github-actions-common reusable workflow"
git push origin test/github-actions-common
```

### Phase 3 : Migration des Autres Projets

1. Créer un guide de migration pour les équipes
2. Fournir le template `.github/workflows/ci.yml`
3. Accompagner les équipes dans la migration
4. Migrer projet par projet

---

## ✅ Checklist

### Repository Partagé

- [ ] Créer `tourem/github-actions-common` sur GitHub
- [ ] Copier le workflow réutilisable
- [ ] Copier la documentation
- [ ] Copier les exemples
- [ ] Tester avec un projet pilote

### Projet Actuel

- [ ] Tester le workflow simplifié
- [ ] Valider les builds Maven
- [ ] Valider les images Docker
- [ ] Comparer avec l'ancien workflow
- [ ] Merger si OK

### Documentation

- [x] Créer le workflow réutilisable
- [x] Créer la documentation (README, USAGE)
- [x] Créer les exemples
- [x] Créer la comparaison Jenkinsfile
- [x] Créer la stratégie de migration

---

## 📊 Comparaison Finale

| Aspect | Jenkins | GitHub Actions (Avant) | GitHub Actions (Après) |
|--------|---------|------------------------|------------------------|
| **Fichier config** | `Jenkinsfile` | `.github/workflows/ci.yml` | `.github/workflows/ci.yml` |
| **Lignes de code** | ~40 | ~200 | ~30 |
| **Complexité** | ⭐ Faible | ⭐⭐⭐⭐⭐ Élevée | ⭐ Faible |
| **Connaissance requise** | Pipeline Jenkins | GitHub Actions | **Aucune** |
| **Registries** | ❌ Non spécifié | ✅ Spécifié | ❌ Non spécifié (auto) |
| **Credentials** | ❌ Non spécifié | ✅ Spécifié | ❌ Non spécifié (auto) |
| **Maintenance** | Pipeline partagé | Chaque projet | Workflow réutilisable |

**Résultat** : Même simplicité que Jenkins, avec les avantages de GitHub Actions !

---

**Date** : 2025-11-03  
**Version** : 1.0  
**Status** : ✅ Solution complète prête à déployer


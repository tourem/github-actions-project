# GitHub Configuration

Ce dossier contient la configuration GitHub pour le projet.

## 📁 Structure

```
.github/
├── workflows/
│   ├── ci.yml           # Workflow CI/CD principal
│   └── settings.xml     # Configuration Maven pour GitHub Actions
└── README.md            # Ce fichier
```

## 🔄 Workflows

### ci.yml - CI/CD Pipeline

Workflow principal qui :
- Compile le projet avec Maven
- Exécute les tests
- Crée les packages (JAR et ZIP)
- Publie vers GitHub Packages
- Archive les artifacts

**Déclencheurs** :
- Push sur `main` et `develop`
- Pull Request vers `main` et `develop`
- Exécution manuelle

**Artifacts produits** :
- JARs exécutables Spring Boot
- ZIPs de distribution
- Informations de build

## 📦 GitHub Packages

Les artifacts sont publiés sur :
```
https://maven.pkg.github.com/tourem/github-actions-project
```

### Packages disponibles

- `com.larbotech:task-api:1.0-SNAPSHOT`
- `com.larbotech:task-api:1.0-SNAPSHOT:zip:distribution`
- `com.larbotech:task-batch:1.0-SNAPSHOT`
- `com.larbotech:task-batch:1.0-SNAPSHOT:zip:distribution`

## 🔧 Configuration

### settings.xml

Fichier de configuration Maven utilisé par GitHub Actions pour l'authentification avec GitHub Packages.

Variables utilisées :
- `GITHUB_ACTOR` - Nom d'utilisateur GitHub
- `GITHUB_TOKEN` - Token d'authentification (généré automatiquement)

## 📚 Documentation

Pour plus d'informations, consultez [GITHUB_ACTIONS.md](../GITHUB_ACTIONS.md) à la racine du projet.

## 🚀 Utilisation

### Déclencher manuellement le workflow

Via l'interface GitHub :
1. Aller sur https://github.com/tourem/github-actions-project/actions
2. Sélectionner "CI/CD Pipeline"
3. Cliquer sur "Run workflow"

Via GitHub CLI :
```bash
gh workflow run ci.yml
```

### Voir les résultats

```bash
# Lister les runs
gh run list

# Voir les détails
gh run view <run-id>

# Télécharger les artifacts
gh run download <run-id>
```

## ✅ Status

[![CI/CD Pipeline](https://github.com/tourem/github-actions-project/actions/workflows/ci.yml/badge.svg)](https://github.com/tourem/github-actions-project/actions/workflows/ci.yml)

